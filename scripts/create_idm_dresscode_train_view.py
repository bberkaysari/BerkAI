from __future__ import annotations

import argparse
import json
import os
import shutil
from concurrent.futures import ThreadPoolExecutor, as_completed
from pathlib import Path

import numpy as np
from numpy.linalg import lstsq
from PIL import Image, ImageDraw, ImageFilter

try:
    import cv2
except ImportError:
    cv2 = None


LABEL_MAP = {
    "background": 0,
    "hat": 1,
    "hair": 2,
    "sunglasses": 3,
    "upper_clothes": 4,
    "skirt": 5,
    "pants": 6,
    "dress": 7,
    "belt": 8,
    "left_shoe": 9,
    "right_shoe": 10,
    "head": 11,
    "left_leg": 12,
    "right_leg": 13,
    "left_arm": 14,
    "right_arm": 15,
    "bag": 16,
    "scarf": 17,
}

CAPTION_FALLBACKS = {
    "upper_body": "upper body garment",
    "lower_body": "lower body garment",
    "dresses": "dress",
}


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description=(
            "Create an IDM-VTON train_xl.py-compatible DressCode dataset view. "
            "Images are hardlinked by default to avoid duplicating the raw dataset."
        )
    )
    parser.add_argument("--source-root", default=r"C:\USB_DressCode_Backup\DressCode")
    parser.add_argument("--output-root", default=r"C:\USB_DressCode_Backup\DressCode_IDM_Train")
    parser.add_argument("--category", default="upper_body", choices=["upper_body", "lower_body", "dresses"])
    parser.add_argument("--train-limit", type=int, default=0, help="0 means all train pairs.")
    parser.add_argument("--test-limit", type=int, default=0, help="0 means all paired test pairs.")
    parser.add_argument("--workers", type=int, default=8)
    parser.add_argument("--force", action="store_true")
    parser.add_argument(
        "--link-mode",
        default="hardlink",
        choices=["hardlink", "copy"],
        help="Hardlinks require source and output to be on the same Windows drive.",
    )
    return parser.parse_args()


def read_pairs(path: Path, limit: int) -> list[tuple[str, str]]:
    pairs: list[tuple[str, str]] = []
    with path.open("r", encoding="utf-8") as file:
        for raw_line in file:
            raw_line = raw_line.strip()
            if not raw_line:
                continue
            parts = raw_line.split()
            if len(parts) < 2:
                raise ValueError(f"Malformed pair line in {path}: {raw_line!r}")
            pairs.append((parts[0], parts[1]))
            if limit and len(pairs) >= limit:
                break
    return pairs


def load_captions(path: Path) -> dict[str, str]:
    captions: dict[str, str] = {}
    if not path.exists():
        return captions

    with path.open("r", encoding="utf-8") as file:
        for raw_line in file:
            raw_line = raw_line.strip()
            if not raw_line:
                continue
            name, *words = raw_line.split()
            captions[name] = " ".join(words)
    return captions


def link_or_copy(source: Path, target: Path, link_mode: str, force: bool) -> None:
    if not source.exists():
        raise FileNotFoundError(f"Missing source file: {source}")

    target.parent.mkdir(parents=True, exist_ok=True)
    if target.exists():
        if not force:
            return
        target.unlink()

    if link_mode == "copy":
        shutil.copy2(source, target)
        return

    try:
        os.link(source, target)
    except OSError:
        shutil.copy2(source, target)


def dilate(mask: np.ndarray, kernel_size: int, iterations: int) -> np.ndarray:
    if cv2 is not None:
        kernel = np.ones((kernel_size, kernel_size), np.uint8)
        return cv2.dilate(mask.astype(np.uint8), kernel, iterations=iterations) > 0

    size = kernel_size if kernel_size % 2 == 1 else kernel_size + 1
    image = Image.fromarray((mask > 0).astype(np.uint8) * 255, mode="L")
    for _ in range(iterations):
        image = image.filter(ImageFilter.MaxFilter(size))
    return np.array(image) > 0


def get_agnostic_mask(parse_array: np.ndarray, pose_data: np.ndarray, category: str) -> np.ndarray:
    parse_shape = parse_array > 0
    parse_head = (
        (parse_array == 1)
        | (parse_array == 2)
        | (parse_array == 3)
        | (parse_array == 11)
    )

    parser_mask_fixed = (
        (parse_array == LABEL_MAP["hair"])
        | (parse_array == LABEL_MAP["left_shoe"])
        | (parse_array == LABEL_MAP["right_shoe"])
        | (parse_array == LABEL_MAP["hat"])
        | (parse_array == LABEL_MAP["sunglasses"])
        | (parse_array == LABEL_MAP["scarf"])
        | (parse_array == LABEL_MAP["bag"])
    )
    parser_mask_changeable = parse_array == LABEL_MAP["background"]
    arms = (parse_array == LABEL_MAP["left_arm"]) | (parse_array == LABEL_MAP["right_arm"])

    if category == "dresses":
        parse_mask = (
            (parse_array == LABEL_MAP["dress"])
            | (parse_array == LABEL_MAP["left_leg"])
            | (parse_array == LABEL_MAP["right_leg"])
        )
        parser_mask_changeable |= parse_shape & ~parser_mask_fixed
    elif category == "upper_body":
        parse_mask = parse_array == LABEL_MAP["upper_clothes"]
        parser_mask_fixed |= (parse_array == LABEL_MAP["skirt"]) | (parse_array == LABEL_MAP["pants"])
        parser_mask_changeable |= parse_shape & ~parser_mask_fixed
    elif category == "lower_body":
        parse_mask = (
            (parse_array == LABEL_MAP["pants"])
            | (parse_array == LABEL_MAP["left_leg"])
            | (parse_array == LABEL_MAP["right_leg"])
        )
        parser_mask_fixed |= (
            (parse_array == LABEL_MAP["upper_clothes"])
            | (parse_array == LABEL_MAP["left_arm"])
            | (parse_array == LABEL_MAP["right_arm"])
        )
        parser_mask_changeable |= parse_shape & ~parser_mask_fixed
    else:
        raise ValueError(f"Unsupported category: {category}")

    height, width = parse_array.shape

    if category in {"dresses", "upper_body"}:
        im_arms = Image.new("L", (width, height))
        arms_draw = ImageDraw.Draw(im_arms)
        scale = height / 512.0
        shoulder_right = tuple(np.multiply(pose_data[2, :2], scale))
        shoulder_left = tuple(np.multiply(pose_data[5, :2], scale))
        elbow_right = tuple(np.multiply(pose_data[3, :2], scale))
        elbow_left = tuple(np.multiply(pose_data[6, :2], scale))
        wrist_right = tuple(np.multiply(pose_data[4, :2], scale))
        wrist_left = tuple(np.multiply(pose_data[7, :2], scale))

        if wrist_right[0] <= 1.0 and wrist_right[1] <= 1.0:
            if elbow_right[0] <= 1.0 and elbow_right[1] <= 1.0:
                arms_draw.line([wrist_left, elbow_left, shoulder_left, shoulder_right], "white", 30, "curve")
            else:
                arms_draw.line([wrist_left, elbow_left, shoulder_left, shoulder_right, elbow_right], "white", 30, "curve")
        elif wrist_left[0] <= 1.0 and wrist_left[1] <= 1.0:
            if elbow_left[0] <= 1.0 and elbow_left[1] <= 1.0:
                arms_draw.line([shoulder_left, shoulder_right, elbow_right, wrist_right], "white", 30, "curve")
            else:
                arms_draw.line([elbow_left, shoulder_left, shoulder_right, elbow_right, wrist_right], "white", 30, "curve")
        else:
            arms_draw.line([wrist_left, elbow_left, shoulder_left, shoulder_right, elbow_right, wrist_right], "white", 30, "curve")

        im_arms_np = np.array(im_arms) > 0
        if height > 512:
            im_arms_np = dilate(im_arms_np, 10, 5)
        elif height > 256:
            im_arms_np = dilate(im_arms_np, 5, 5)

        hands = ~im_arms_np & arms
        parse_mask |= im_arms_np
        parser_mask_fixed |= hands

    parse_head_2 = parse_head.copy()
    if category in {"dresses", "upper_body"}:
        points = [
            np.multiply(pose_data[2, :2], height / 512.0),
            np.multiply(pose_data[5, :2], height / 512.0),
        ]
        x_coords, y_coords = zip(*points)
        a = np.vstack([x_coords, np.ones(len(x_coords))]).T
        m, c = lstsq(a, y_coords, rcond=None)[0]
        for x in range(width):
            y = x * m + c
            y_cut = int(y - 20 * (height / 512.0))
            parse_head_2[max(y_cut, 0):, x] = False

    parser_mask_fixed |= parse_head_2
    parse_mask |= parse_mask | (parse_head & ~parse_head_2)

    if height > 512:
        parse_mask = dilate(parse_mask, 20, 5)
    elif height > 256:
        parse_mask = dilate(parse_mask, 10, 5)
    else:
        parse_mask = dilate(parse_mask, 5, 5)

    parse_mask = parser_mask_changeable & ~parse_mask
    return parse_mask | parser_mask_fixed


def save_inpaint_mask(source_category: Path, target_mask: Path, image_name: str, category: str, force: bool) -> None:
    if target_mask.exists() and not force:
        return

    base = image_name.replace("_0.jpg", "")
    parse_path = source_category / "label_maps" / f"{base}_4.png"
    pose_path = source_category / "keypoints" / f"{base}_2.json"

    with Image.open(parse_path) as parse_image:
        parse_array = np.array(parse_image.resize((768, 1024), Image.NEAREST))

    with pose_path.open("r", encoding="utf-8") as file:
        pose_data = np.array(json.load(file)["keypoints"], dtype=np.float32)

    agnostic_mask = get_agnostic_mask(parse_array, pose_data, category)
    inpaint_mask = (~agnostic_mask).astype(np.uint8) * 255
    target_mask.parent.mkdir(parents=True, exist_ok=True)
    Image.fromarray(inpaint_mask, mode="L").save(target_mask)


def annotation_for(file_name: str, caption: str, category: str) -> dict:
    return {
        "file_name": file_name,
        "category_name": category.upper(),
        "tag_info": [
            {
                "tag_name": "item",
                "tag_category": caption,
            }
        ],
    }


def prepare_split(
    source_category: Path,
    output_dataset: Path,
    category: str,
    phase: str,
    source_pair_file: str,
    captions: dict[str, str],
    limit: int,
    workers: int,
    link_mode: str,
    force: bool,
) -> None:
    pairs = read_pairs(source_category / source_pair_file, limit)
    phase_root = output_dataset / phase
    for folder in ("image", "cloth", "image-densepose", "agnostic-mask"):
        (phase_root / folder).mkdir(parents=True, exist_ok=True)

    written_pairs: list[str] = []
    annotations: list[dict] = []
    mask_jobs = []

    with ThreadPoolExecutor(max_workers=workers) as executor:
        for image_name, garment_name in pairs:
            target_cloth_name = image_name
            caption = captions.get(garment_name, CAPTION_FALLBACKS[category])

            link_or_copy(source_category / "images" / image_name, phase_root / "image" / image_name, link_mode, force)
            link_or_copy(source_category / "images" / garment_name, phase_root / "cloth" / target_cloth_name, link_mode, force)
            link_or_copy(source_category / "image-densepose" / image_name, phase_root / "image-densepose" / image_name, link_mode, force)

            target_mask = phase_root / "agnostic-mask" / image_name.replace(".jpg", "_mask.png")
            mask_jobs.append(executor.submit(save_inpaint_mask, source_category, target_mask, image_name, category, force))

            written_pairs.append(f"{image_name}\t{target_cloth_name}\n")
            annotations.append(annotation_for(target_cloth_name, caption, category))

        completed = 0
        for future in as_completed(mask_jobs):
            future.result()
            completed += 1
            if completed % 500 == 0 or completed == len(mask_jobs):
                print(f"[{category}:{phase}] masks {completed}/{len(mask_jobs)}")

    (output_dataset / f"{phase}_pairs.txt").write_text("".join(written_pairs), encoding="ascii")
    tagged_path = phase_root / f"vitonhd_{phase}_tagged.json"
    tagged_path.write_text(json.dumps({"data": annotations}, indent=2), encoding="ascii")

    print(f"[{category}:{phase}] pairs={len(pairs)} root={phase_root}")


def main() -> None:
    args = parse_args()
    source_category = Path(args.source_root) / args.category
    output_dataset = Path(args.output_root) / args.category

    if not source_category.exists():
        raise FileNotFoundError(f"Source category not found: {source_category}")

    if output_dataset.exists() and args.force:
        shutil.rmtree(output_dataset)

    captions = load_captions(source_category / "dc_caption.txt")
    prepare_split(
        source_category=source_category,
        output_dataset=output_dataset,
        category=args.category,
        phase="train",
        source_pair_file="train_pairs.txt",
        captions=captions,
        limit=args.train_limit,
        workers=args.workers,
        link_mode=args.link_mode,
        force=args.force,
    )
    prepare_split(
        source_category=source_category,
        output_dataset=output_dataset,
        category=args.category,
        phase="test",
        source_pair_file="test_pairs_paired.txt",
        captions=captions,
        limit=args.test_limit,
        workers=args.workers,
        link_mode=args.link_mode,
        force=args.force,
    )

    print(f"\nCreated train_xl-compatible dataset: {output_dataset}")
    print("Use this path as --data_dir for IDM-VTON train_xl.py")


if __name__ == "__main__":
    main()
