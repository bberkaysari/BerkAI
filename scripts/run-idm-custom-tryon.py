import argparse
import os
import sys
from contextlib import nullcontext
from pathlib import Path

import numpy as np
import torch
from PIL import Image
from torchvision import transforms
from torchvision.transforms.functional import to_pil_image
from transformers import (
    AutoTokenizer,
    CLIPImageProcessor,
    CLIPTextModel,
    CLIPTextModelWithProjection,
    CLIPVisionModelWithProjection,
)
from diffusers import AutoencoderKL, DDPMScheduler


def pil_to_binary_mask(pil_image, threshold=0):
    np_image = np.array(pil_image)
    grayscale_image = Image.fromarray(np_image).convert("L")
    binary_mask = np.array(grayscale_image) > threshold
    mask = (binary_mask.astype(np.uint8) * 255)
    return Image.fromarray(mask)


def load_idm_modules(idm_root):
    sys.path.insert(0, str(idm_root))
    sys.path.insert(0, str(idm_root / "gradio_demo"))

    from gradio_demo import apply_net  # noqa: PLC0415
    from gradio_demo.utils_mask import get_mask_location  # noqa: PLC0415
    from preprocess.humanparsing.run_parsing import Parsing  # noqa: PLC0415
    from preprocess.openpose.run_openpose import OpenPose  # noqa: PLC0415
    from detectron2.data.detection_utils import (  # noqa: PLC0415
        _apply_exif_orientation,
        convert_PIL_to_numpy,
    )
    from src.tryon_pipeline import StableDiffusionXLInpaintPipeline as TryonPipeline  # noqa: PLC0415
    from src.unet_hacked_garmnet import UNet2DConditionModel as RefUNet  # noqa: PLC0415
    from src.unet_hacked_tryon import UNet2DConditionModel as TryonUNet  # noqa: PLC0415

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


def load_pipeline(mods, checkpoint, device):
    dtype = torch.float16 if device.startswith("cuda") else torch.float32

    unet = mods["TryonUNet"].from_pretrained(checkpoint, subfolder="unet", torch_dtype=dtype)
    unet.requires_grad_(False)

    unet_encoder = mods["RefUNet"].from_pretrained(
        checkpoint,
        subfolder="unet_encoder",
        torch_dtype=dtype,
    )
    unet_encoder.requires_grad_(False)

    tokenizer_one = AutoTokenizer.from_pretrained(
        checkpoint,
        subfolder="tokenizer",
        use_fast=False,
    )
    tokenizer_two = AutoTokenizer.from_pretrained(
        checkpoint,
        subfolder="tokenizer_2",
        use_fast=False,
    )
    scheduler = DDPMScheduler.from_pretrained(checkpoint, subfolder="scheduler")

    text_encoder_one = CLIPTextModel.from_pretrained(
        checkpoint,
        subfolder="text_encoder",
        torch_dtype=dtype,
    )
    text_encoder_two = CLIPTextModelWithProjection.from_pretrained(
        checkpoint,
        subfolder="text_encoder_2",
        torch_dtype=dtype,
    )
    image_encoder = CLIPVisionModelWithProjection.from_pretrained(
        checkpoint,
        subfolder="image_encoder",
        torch_dtype=dtype,
    )
    vae = AutoencoderKL.from_pretrained(
        checkpoint,
        subfolder="vae",
        torch_dtype=dtype,
    )
    feature_extractor = CLIPImageProcessor.from_pretrained(
        checkpoint,
        subfolder="feature_extractor",
    )

    for module in (text_encoder_one, text_encoder_two, image_encoder, vae):
        module.requires_grad_(False)

    pipe = mods["TryonPipeline"].from_pretrained(
        checkpoint,
        unet=unet,
        vae=vae,
        feature_extractor=feature_extractor,
        text_encoder=text_encoder_one,
        text_encoder_2=text_encoder_two,
        tokenizer=tokenizer_one,
        tokenizer_2=tokenizer_two,
        scheduler=scheduler,
        image_encoder=image_encoder,
        torch_dtype=dtype,
    )
    pipe.unet_encoder = unet_encoder
    pipe.to(device)
    pipe.unet_encoder.to(device)
    return pipe, dtype


def centered_3x4_crop(image):
    width, height = image.size
    target_width = int(min(width, height * (3 / 4)))
    target_height = int(min(height, width * (4 / 3)))
    left = int((width - target_width) / 2)
    top = int((height - target_height) / 2)
    right = left + target_width
    bottom = top + target_height
    return image.crop((left, top, right, bottom)), (left, top, image.size, (target_width, target_height))


def run_tryon(args):
    idm_root = Path(args.idm_root).resolve()
    checkpoint = Path(args.checkpoint).resolve()
    output_dir = Path(args.output_dir).resolve()
    output_dir.mkdir(parents=True, exist_ok=True)

    os.chdir(idm_root)
    mods = load_idm_modules(idm_root)

    device = "cuda:0" if torch.cuda.is_available() and not args.cpu else "cpu"
    print(f"Using device: {device}")
    print(f"Using checkpoint: {checkpoint}")

    pipe, dtype = load_pipeline(mods, str(checkpoint), device)
    parsing_model = mods["Parsing"](0)
    openpose_model = mods["OpenPose"](0)
    openpose_model.preprocessor.body_estimation.model.to(device)

    tensor_transform = transforms.Compose(
        [
            transforms.ToTensor(),
            transforms.Normalize([0.5], [0.5]),
        ]
    )

    garment_img = Image.open(args.garment).convert("RGB").resize((768, 1024))
    human_img_orig = Image.open(args.person).convert("RGB")

    crop_meta = None
    if args.auto_crop:
        cropped_img, crop_meta = centered_3x4_crop(human_img_orig)
        human_img = cropped_img.resize((768, 1024))
    else:
        human_img = human_img_orig.resize((768, 1024))

    if args.auto_mask:
        keypoints = openpose_model(human_img.resize((384, 512)))
        model_parse, _ = parsing_model(human_img.resize((384, 512)))
        mask, _ = mods["get_mask_location"]("hd", args.category, model_parse, keypoints)
        mask = mask.resize((768, 1024))
    elif args.mask:
        mask = pil_to_binary_mask(Image.open(args.mask).convert("RGB").resize((768, 1024)))
    else:
        raise ValueError("Provide --auto-mask or --mask.")

    mask_gray = (1 - transforms.ToTensor()(mask)) * tensor_transform(human_img)
    mask_gray = to_pil_image((mask_gray + 1.0) / 2.0)

    human_for_densepose = mods["_apply_exif_orientation"](human_img.resize((384, 512)))
    human_np = mods["convert_PIL_to_numpy"](human_for_densepose, format="BGR")
    detectron_device = "cuda" if device.startswith("cuda") else "cpu"
    densepose_args = mods["apply_net"].create_argument_parser().parse_args(
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

    autocast = torch.cuda.amp.autocast if device.startswith("cuda") else nullcontext
    with torch.no_grad(), autocast():
        prompt = "model is wearing " + args.prompt
        negative_prompt = "monochrome, lowres, bad anatomy, worst quality, low quality"
        (
            prompt_embeds,
            negative_prompt_embeds,
            pooled_prompt_embeds,
            negative_pooled_prompt_embeds,
        ) = pipe.encode_prompt(
            prompt,
            num_images_per_prompt=1,
            do_classifier_free_guidance=True,
            negative_prompt=negative_prompt,
        )

        cloth_prompt = "a photo of " + args.prompt
        (prompt_embeds_c, _, _, _) = pipe.encode_prompt(
            [cloth_prompt],
            num_images_per_prompt=1,
            do_classifier_free_guidance=False,
            negative_prompt=[negative_prompt],
        )

        pose_tensor = tensor_transform(pose_img).unsqueeze(0).to(device, dtype)
        garment_tensor = tensor_transform(garment_img).unsqueeze(0).to(device, dtype)
        generator = torch.Generator(device).manual_seed(args.seed) if args.seed is not None else None

        images = pipe(
            prompt_embeds=prompt_embeds.to(device, dtype),
            negative_prompt_embeds=negative_prompt_embeds.to(device, dtype),
            pooled_prompt_embeds=pooled_prompt_embeds.to(device, dtype),
            negative_pooled_prompt_embeds=negative_pooled_prompt_embeds.to(device, dtype),
            num_inference_steps=args.steps,
            generator=generator,
            strength=1.0,
            pose_img=pose_tensor,
            text_embeds_cloth=prompt_embeds_c.to(device, dtype),
            cloth=garment_tensor,
            mask_image=mask,
            image=human_img,
            height=1024,
            width=768,
            ip_adapter_image=garment_img.resize((768, 1024)),
            guidance_scale=args.guidance_scale,
        )[0]

    result = images[0]
    if crop_meta is not None:
        left, top, original_size, crop_size = crop_meta
        pasted = human_img_orig.copy()
        pasted.paste(result.resize(crop_size), (left, top))
        result = pasted

    result_path = output_dir / "tryon_ft5000.png"
    masked_path = output_dir / "masked_ft5000.png"
    result.save(result_path)
    mask_gray.save(masked_path)
    print(f"Saved result: {result_path}")
    print(f"Saved masked: {masked_path}")


def parse_args():
    parser = argparse.ArgumentParser(description="Run arbitrary-image IDM-VTON try-on with a local checkpoint.")
    parser.add_argument("--idm-root", required=True, help="Path to the IDM-VTON repository.")
    parser.add_argument("--checkpoint", required=True, help="Path to a full Diffusers IDM-VTON checkpoint.")
    parser.add_argument("--person", required=True, help="Person image.")
    parser.add_argument("--garment", required=True, help="Garment/product image.")
    parser.add_argument("--prompt", required=True, help="Garment text prompt.")
    parser.add_argument("--output-dir", required=True, help="Directory to save output images.")
    parser.add_argument("--category", default="upper_body", choices=["upper_body", "lower_body", "dresses"])
    parser.add_argument("--steps", type=int, default=20)
    parser.add_argument("--seed", type=int, default=42)
    parser.add_argument("--guidance-scale", type=float, default=2.0)
    parser.add_argument("--auto-mask", action="store_true")
    parser.add_argument("--auto-crop", action="store_true")
    parser.add_argument("--mask", default=None, help="Optional manual mask if --auto-mask is not used.")
    parser.add_argument("--cpu", action="store_true", help="Force CPU. Mostly for debugging; very slow.")
    return parser.parse_args()


if __name__ == "__main__":
    run_tryon(parse_args())
