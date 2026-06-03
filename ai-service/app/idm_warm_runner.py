from __future__ import annotations

import os
import sys
import threading
from contextlib import nullcontext
from pathlib import Path

import numpy as np
from PIL import Image


class IDMWarmRunner:
    def __init__(self, *, idm_root: Path, checkpoint: Path, device: str | None = None) -> None:
        self.idm_root = idm_root.resolve()
        self.checkpoint = checkpoint.resolve()
        self.device = device
        self._lock = threading.Lock()
        self._loaded = False

    @property
    def is_loaded(self) -> bool:
        return self._loaded

    def load(self) -> None:
        if self._loaded:
            return

        self._ensure_paths()
        os.chdir(self.idm_root)
        self._import_runtime()

        self.device = self.device or ("cuda:0" if self.torch.cuda.is_available() else "cpu")
        self.dtype = self.torch.float16 if self.device.startswith("cuda") else self.torch.float32

        self.mods = self._load_idm_modules()
        self.pipe = self._load_pipeline()
        self.parsing_model = self.mods["Parsing"](0)
        self.openpose_model = self.mods["OpenPose"](0)
        self.openpose_model.preprocessor.body_estimation.model.to(self.device)
        self.tensor_transform = self.transforms.Compose(
            [
                self.transforms.ToTensor(),
                self.transforms.Normalize([0.5], [0.5]),
            ]
        )
        self._loaded = True

    def run(
        self,
        *,
        person_path: Path,
        garment_path: Path,
        prompt: str,
        output_dir: Path,
        category: str = "upper_body",
        steps: int = 20,
        seed: int = 42,
        auto_mask: bool = True,
        auto_crop: bool = True,
        guidance_scale: float = 2.0,
    ) -> tuple[Path, Path | None]:
        with self._lock:
            self.load()
            output_dir.mkdir(parents=True, exist_ok=True)

            garment_img = Image.open(garment_path).convert("RGB").resize((768, 1024))
            human_img_orig = Image.open(person_path).convert("RGB")

            crop_meta = None
            if auto_crop:
                cropped_img, crop_meta = self._centered_3x4_crop(human_img_orig)
                human_img = cropped_img.resize((768, 1024))
            else:
                human_img = human_img_orig.resize((768, 1024))

            if auto_mask:
                keypoints = self.openpose_model(human_img.resize((384, 512)))
                model_parse, _ = self.parsing_model(human_img.resize((384, 512)))
                mask, _ = self.mods["get_mask_location"]("hd", category, model_parse, keypoints)
                mask = mask.resize((768, 1024))
            else:
                raise ValueError("Warm runner currently requires auto_mask=True.")

            mask_gray = (1 - self.transforms.ToTensor()(mask)) * self.tensor_transform(human_img)
            mask_gray = self.to_pil_image((mask_gray + 1.0) / 2.0)

            human_for_densepose = self.mods["_apply_exif_orientation"](human_img.resize((384, 512)))
            human_np = self.mods["convert_PIL_to_numpy"](human_for_densepose, format="BGR")
            detectron_device = "cuda" if self.device.startswith("cuda") else "cpu"
            densepose_args = self.mods["apply_net"].create_argument_parser().parse_args(
                (
                    "show",
                    "./configs/densepose_rcnn_R_50_FPN_s1x.yaml",
                    "./ckpt/densepose/model_final_162be9.pkl",
                    "dp_segm",
                    "-v",
                    "--opts",
                    "MODEL.DEVICE",
                    detectron_device,
                )
            )
            pose_img = densepose_args.func(densepose_args, human_np)
            pose_img = Image.fromarray(pose_img[:, :, ::-1]).resize((768, 1024))

            autocast = self.torch.cuda.amp.autocast if self.device.startswith("cuda") else nullcontext
            with self.torch.no_grad(), autocast():
                model_prompt = "model is wearing " + prompt
                negative_prompt = "monochrome, lowres, bad anatomy, worst quality, low quality"
                (
                    prompt_embeds,
                    negative_prompt_embeds,
                    pooled_prompt_embeds,
                    negative_pooled_prompt_embeds,
                ) = self.pipe.encode_prompt(
                    model_prompt,
                    num_images_per_prompt=1,
                    do_classifier_free_guidance=True,
                    negative_prompt=negative_prompt,
                )

                cloth_prompt = "a photo of " + prompt
                (prompt_embeds_c, _, _, _) = self.pipe.encode_prompt(
                    [cloth_prompt],
                    num_images_per_prompt=1,
                    do_classifier_free_guidance=False,
                    negative_prompt=[negative_prompt],
                )

                pose_tensor = self.tensor_transform(pose_img).unsqueeze(0).to(self.device, self.dtype)
                garment_tensor = self.tensor_transform(garment_img).unsqueeze(0).to(self.device, self.dtype)
                generator = self.torch.Generator(self.device).manual_seed(seed) if seed is not None else None

                images = self.pipe(
                    prompt_embeds=prompt_embeds.to(self.device, self.dtype),
                    negative_prompt_embeds=negative_prompt_embeds.to(self.device, self.dtype),
                    pooled_prompt_embeds=pooled_prompt_embeds.to(self.device, self.dtype),
                    negative_pooled_prompt_embeds=negative_pooled_prompt_embeds.to(self.device, self.dtype),
                    num_inference_steps=steps,
                    generator=generator,
                    strength=1.0,
                    pose_img=pose_tensor,
                    text_embeds_cloth=prompt_embeds_c.to(self.device, self.dtype),
                    cloth=garment_tensor,
                    mask_image=mask,
                    image=human_img,
                    height=1024,
                    width=768,
                    ip_adapter_image=garment_img.resize((768, 1024)),
                    guidance_scale=guidance_scale,
                )[0]

            result = images[0]
            if crop_meta is not None:
                left, top, crop_size = crop_meta
                pasted = human_img_orig.copy()
                pasted.paste(result.resize(crop_size), (left, top))
                result = pasted

            result_path = output_dir / "tryon_warm.png"
            masked_path = output_dir / "masked_warm.png"
            result.save(result_path)
            mask_gray.save(masked_path)
            return result_path, masked_path

    def _ensure_paths(self) -> None:
        if not self.idm_root.exists():
            raise RuntimeError(f"IDM-VTON repo was not found: {self.idm_root}")
        if not self.checkpoint.exists():
            raise RuntimeError(f"IDM checkpoint was not found: {self.checkpoint}")

    def _import_runtime(self) -> None:
        import torch
        from diffusers import AutoencoderKL, DDPMScheduler
        from torchvision import transforms
        from torchvision.transforms.functional import to_pil_image
        from transformers import (
            AutoTokenizer,
            CLIPImageProcessor,
            CLIPTextModel,
            CLIPTextModelWithProjection,
            CLIPVisionModelWithProjection,
        )

        self.torch = torch
        self.AutoencoderKL = AutoencoderKL
        self.DDPMScheduler = DDPMScheduler
        self.transforms = transforms
        self.to_pil_image = to_pil_image
        self.AutoTokenizer = AutoTokenizer
        self.CLIPImageProcessor = CLIPImageProcessor
        self.CLIPTextModel = CLIPTextModel
        self.CLIPTextModelWithProjection = CLIPTextModelWithProjection
        self.CLIPVisionModelWithProjection = CLIPVisionModelWithProjection

    def _load_idm_modules(self) -> dict[str, object]:
        sys.path.insert(0, str(self.idm_root))
        sys.path.insert(0, str(self.idm_root / "gradio_demo"))

        from gradio_demo import apply_net
        from gradio_demo.utils_mask import get_mask_location
        from preprocess.humanparsing.run_parsing import Parsing
        from preprocess.openpose.run_openpose import OpenPose
        from detectron2.data.detection_utils import _apply_exif_orientation, convert_PIL_to_numpy
        from src.tryon_pipeline import StableDiffusionXLInpaintPipeline as TryonPipeline
        from src.unet_hacked_garmnet import UNet2DConditionModel as RefUNet
        from src.unet_hacked_tryon import UNet2DConditionModel as TryonUNet

        return {
            "apply_net": apply_net,
            "get_mask_location": get_mask_location,
            "Parsing": Parsing,
            "OpenPose": OpenPose,
            "TryonPipeline": TryonPipeline,
            "RefUNet": RefUNet,
            "TryonUNet": TryonUNet,
            "convert_PIL_to_numpy": convert_PIL_to_numpy,
            "_apply_exif_orientation": _apply_exif_orientation,
        }

    def _load_pipeline(self):
        unet = self.mods["TryonUNet"].from_pretrained(
            self.checkpoint,
            subfolder="unet",
            torch_dtype=self.dtype,
        )
        unet.requires_grad_(False)

        unet_encoder = self.mods["RefUNet"].from_pretrained(
            self.checkpoint,
            subfolder="unet_encoder",
            torch_dtype=self.dtype,
        )
        unet_encoder.requires_grad_(False)

        tokenizer_one = self.AutoTokenizer.from_pretrained(
            self.checkpoint,
            subfolder="tokenizer",
            use_fast=False,
        )
        tokenizer_two = self.AutoTokenizer.from_pretrained(
            self.checkpoint,
            subfolder="tokenizer_2",
            use_fast=False,
        )
        scheduler = self.DDPMScheduler.from_pretrained(self.checkpoint, subfolder="scheduler")

        text_encoder_one = self.CLIPTextModel.from_pretrained(
            self.checkpoint,
            subfolder="text_encoder",
            torch_dtype=self.dtype,
        )
        text_encoder_two = self.CLIPTextModelWithProjection.from_pretrained(
            self.checkpoint,
            subfolder="text_encoder_2",
            torch_dtype=self.dtype,
        )
        image_encoder = self.CLIPVisionModelWithProjection.from_pretrained(
            self.checkpoint,
            subfolder="image_encoder",
            torch_dtype=self.dtype,
        )
        vae = self.AutoencoderKL.from_pretrained(
            self.checkpoint,
            subfolder="vae",
            torch_dtype=self.dtype,
        )
        feature_extractor = self.CLIPImageProcessor.from_pretrained(
            self.checkpoint,
            subfolder="feature_extractor",
        )

        for module in (text_encoder_one, text_encoder_two, image_encoder, vae):
            module.requires_grad_(False)

        pipe = self.mods["TryonPipeline"].from_pretrained(
            self.checkpoint,
            unet=unet,
            vae=vae,
            feature_extractor=feature_extractor,
            text_encoder=text_encoder_one,
            text_encoder_2=text_encoder_two,
            tokenizer=tokenizer_one,
            tokenizer_2=tokenizer_two,
            scheduler=scheduler,
            image_encoder=image_encoder,
            torch_dtype=self.dtype,
        )
        pipe.unet_encoder = unet_encoder
        pipe.to(self.device)
        pipe.unet_encoder.to(self.device)
        return pipe

    @staticmethod
    def _centered_3x4_crop(image: Image.Image) -> tuple[Image.Image, tuple[int, int, tuple[int, int]]]:
        width, height = image.size
        target_width = int(min(width, height * (3 / 4)))
        target_height = int(min(height, width * (4 / 3)))
        left = int((width - target_width) / 2)
        top = int((height - target_height) / 2)
        right = left + target_width
        bottom = top + target_height
        return image.crop((left, top, right, bottom)), (left, top, (target_width, target_height))
