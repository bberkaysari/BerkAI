from __future__ import annotations

import argparse
from concurrent.futures import ThreadPoolExecutor, as_completed
from pathlib import Path

from PIL import Image


CAPTIONS = {
    "upper_body": "upper body garment",
    "lower_body": "lower body garment",
    "dresses": "dress",
}


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Add IDM-VTON DressCode assets: image-densepose and dc_caption.txt."
    )
    parser.add_argument("--source-root", default=r"C:\USB_DressCode_Backup\DressCode")
    parser.add_argument("--categories", nargs="+", default=["upper_body"])
    parser.add_argument("--workers", type=int, default=8)
    parser.add_argument("--quality", type=int, default=95)
    parser.add_argument("--limit", type=int, default=0)
    parser.add_argument("--force", action="store_true")
    return parser.parse_args()


def convert_densepose(source_png: Path, target_jpg: Path, quality: int, force: bool) -> bool:
    if target_jpg.exists() and not force:
        return False

    target_jpg.parent.mkdir(parents=True, exist_ok=True)
    with Image.open(source_png) as image:
        image.convert("RGB").save(target_jpg, format="JPEG", quality=quality)
    return True


def prepare_category(
    source_root: Path,
    category: str,
    workers: int,
    quality: int,
    limit: int,
    force: bool,
) -> None:
    category_root = source_root / category
    if not category_root.exists():
        raise FileNotFoundError(f"Category not found: {category_root}")

    dense_root = category_root / "dense"
    image_densepose_root = category_root / "image-densepose"
    image_densepose_root.mkdir(parents=True, exist_ok=True)

    dense_files = sorted(
        path
        for path in dense_root.glob("*_5.png")
        if not path.name.startswith("._")
    )
    if limit > 0:
        dense_files = dense_files[:limit]

    print(f"\n[{category}] densepose sources: {len(dense_files)}")

    jobs = []
    with ThreadPoolExecutor(max_workers=workers) as executor:
        for source_png in dense_files:
            target_name = source_png.name.replace("_5.png", "_0.jpg")
            target_jpg = image_densepose_root / target_name
            jobs.append(
                executor.submit(
                    convert_densepose,
                    source_png,
                    target_jpg,
                    quality,
                    force,
                )
            )

        converted = 0
        skipped = 0
        for index, future in enumerate(as_completed(jobs), start=1):
            if future.result():
                converted += 1
            else:
                skipped += 1

            if index % 500 == 0 or index == len(jobs):
                print(
                    f"[{category}] image-densepose progress: "
                    f"{index}/{len(jobs)} converted={converted} skipped={skipped}"
                )

    caption = CAPTIONS.get(category, category.replace("_", " "))
    garment_names = sorted(
        path.name
        for path in (category_root / "images").glob("*_1.jpg")
        if not path.name.startswith("._")
    )
    caption_path = category_root / "dc_caption.txt"
    caption_path.write_text(
        "".join(f"{name} {caption}\n" for name in garment_names),
        encoding="ascii",
    )

    print(f"[{category}] dc_caption.txt garments: {len(garment_names)}")
    print(f"[{category}] done: {image_densepose_root}")


def main() -> None:
    args = parse_args()
    source_root = Path(args.source_root)

    for category in args.categories:
        prepare_category(
            source_root=source_root,
            category=category,
            workers=args.workers,
            quality=args.quality,
            limit=args.limit,
            force=args.force,
        )


if __name__ == "__main__":
    main()
