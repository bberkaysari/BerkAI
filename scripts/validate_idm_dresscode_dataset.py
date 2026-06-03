from __future__ import annotations

import argparse
from pathlib import Path

from PIL import Image


PAIR_FILES = (
    "train_pairs.txt",
    "test_pairs_paired.txt",
    "test_pairs_unpaired.txt",
)


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Validate DressCode assets required by IDM-VTON inference_dc.py."
    )
    parser.add_argument("--data-root", default=r"C:\USB_DressCode_Backup\DressCode")
    parser.add_argument(
        "--categories",
        nargs="+",
        default=["upper_body", "lower_body", "dresses"],
    )
    parser.add_argument(
        "--max-pairs",
        type=int,
        default=0,
        help="Limit checked pairs per pair file. 0 checks all pairs.",
    )
    parser.add_argument(
        "--sample-images",
        type=int,
        default=3,
        help="Number of densepose images per category to open and inspect.",
    )
    return parser.parse_args()


def read_pair_lines(path: Path, max_pairs: int) -> list[tuple[str, str]]:
    lines: list[tuple[str, str]] = []
    with path.open("r", encoding="utf-8") as file:
        for raw_line in file:
            raw_line = raw_line.strip()
            if not raw_line:
                continue
            parts = raw_line.split()
            if len(parts) < 2:
                raise ValueError(f"Malformed pair line in {path}: {raw_line!r}")
            lines.append((parts[0], parts[1]))
            if max_pairs and len(lines) >= max_pairs:
                break
    return lines


def required_person_assets(category_root: Path, image_name: str) -> list[Path]:
    base = image_name.replace("_0.jpg", "")
    return [
        category_root / "images" / image_name,
        category_root / "keypoints" / f"{base}_2.json",
        category_root / "label_maps" / f"{base}_4.png",
        category_root / "skeletons" / f"{base}_5.jpg",
        category_root / "image-densepose" / image_name,
    ]


def validate_category(data_root: Path, category: str, max_pairs: int, sample_images: int) -> int:
    category_root = data_root / category
    if not category_root.exists():
        print(f"[{category}] ERROR missing category folder: {category_root}")
        return 1

    errors: list[str] = []
    caption_path = category_root / "dc_caption.txt"
    captions: dict[str, str] = {}

    if not caption_path.exists():
        errors.append(f"missing {caption_path}")
    else:
        with caption_path.open("r", encoding="utf-8") as file:
            for line in file:
                line = line.strip()
                if not line:
                    continue
                garment, *words = line.split()
                captions[garment] = " ".join(words)

    print(f"\n[{category}] captions={len(captions)}")

    for pair_file in PAIR_FILES:
        pair_path = category_root / pair_file
        if not pair_path.exists():
            errors.append(f"missing {pair_path}")
            continue

        pairs = read_pair_lines(pair_path, max_pairs)
        checked = 0
        for image_name, garment_name in pairs:
            for path in required_person_assets(category_root, image_name):
                if not path.exists():
                    errors.append(f"{pair_file}: missing {path}")

            garment_path = category_root / "images" / garment_name
            if not garment_path.exists():
                errors.append(f"{pair_file}: missing {garment_path}")

            if garment_name not in captions:
                errors.append(f"{pair_file}: missing caption for {garment_name}")

            checked += 1

        print(f"[{category}] {pair_file}: checked={checked}")

    densepose_files = sorted((category_root / "image-densepose").glob("*_0.jpg"))
    if not densepose_files:
        errors.append(f"missing densepose jpg files in {category_root / 'image-densepose'}")
    else:
        for path in densepose_files[:sample_images]:
            with Image.open(path) as image:
                if image.mode != "RGB":
                    errors.append(f"{path} mode={image.mode}, expected RGB")
                if image.size != (768, 1024):
                    errors.append(f"{path} size={image.size}, expected (768, 1024)")
                if image.format != "JPEG":
                    errors.append(f"{path} format={image.format}, expected JPEG")

    if errors:
        print(f"[{category}] FAILED errors={len(errors)}")
        for error in errors[:25]:
            print(f"  - {error}")
        if len(errors) > 25:
            print(f"  ... {len(errors) - 25} more")
        return 1

    print(f"[{category}] OK")
    return 0


def main() -> None:
    args = parse_args()
    data_root = Path(args.data_root)

    if not data_root.exists():
        raise FileNotFoundError(f"Dataset root not found: {data_root}")

    failures = 0
    for category in args.categories:
        failures += validate_category(
            data_root=data_root,
            category=category,
            max_pairs=args.max_pairs,
            sample_images=args.sample_images,
        )

    if failures:
        raise SystemExit(1)

    print("\nAll requested categories passed IDM-VTON dataset validation.")


if __name__ == "__main__":
    main()
