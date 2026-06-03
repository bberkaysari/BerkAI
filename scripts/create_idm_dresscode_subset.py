from __future__ import annotations

import argparse
import shutil
from pathlib import Path


PAIR_FILES = (
    "train_pairs.txt",
    "test_pairs_paired.txt",
    "test_pairs_unpaired.txt",
)


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Create a small IDM-VTON DressCode subset for quick GPU inference tests."
    )
    parser.add_argument("--source-root", default=r"C:\USB_DressCode_Backup\DressCode")
    parser.add_argument("--output-root", default=r"C:\USB_DressCode_Backup\DressCode_IDM_Eval20")
    parser.add_argument("--category", default="upper_body")
    parser.add_argument("--count", type=int, default=20)
    parser.add_argument("--force", action="store_true")
    return parser.parse_args()


def read_pairs(path: Path, count: int) -> list[tuple[str, str]]:
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
            if len(pairs) >= count:
                break
    return pairs


def person_asset_names(image_name: str) -> dict[str, str]:
    base = image_name.replace("_0.jpg", "")
    return {
        "images": image_name,
        "keypoints": f"{base}_2.json",
        "label_maps": f"{base}_4.png",
        "skeletons": f"{base}_5.jpg",
        "image-densepose": image_name,
    }


def copy_file(source: Path, target: Path) -> None:
    if not source.exists():
        raise FileNotFoundError(f"Missing source file: {source}")
    target.parent.mkdir(parents=True, exist_ok=True)
    if not target.exists():
        shutil.copy2(source, target)


def load_captions(path: Path) -> dict[str, str]:
    captions: dict[str, str] = {}
    with path.open("r", encoding="utf-8") as file:
        for raw_line in file:
            raw_line = raw_line.strip()
            if not raw_line:
                continue
            name, *words = raw_line.split()
            captions[name] = " ".join(words)
    return captions


def main() -> None:
    args = parse_args()
    source_category = Path(args.source_root) / args.category
    output_category = Path(args.output_root) / args.category

    if not source_category.exists():
        raise FileNotFoundError(f"Source category not found: {source_category}")

    if output_category.exists() and args.force:
        shutil.rmtree(output_category)

    for folder in ("images", "keypoints", "label_maps", "skeletons", "image-densepose"):
        (output_category / folder).mkdir(parents=True, exist_ok=True)

    captions = load_captions(source_category / "dc_caption.txt")
    selected_garments: set[str] = set()
    copied_people: set[str] = set()
    copied_images: set[str] = set()

    for pair_file in PAIR_FILES:
        source_pair_path = source_category / pair_file
        pairs = read_pairs(source_pair_path, args.count)
        (output_category / pair_file).write_text(
            "".join(f"{image_name}\t{garment_name}\n" for image_name, garment_name in pairs),
            encoding="ascii",
        )

        for image_name, garment_name in pairs:
            selected_garments.add(garment_name)

            if image_name not in copied_people:
                for folder, asset_name in person_asset_names(image_name).items():
                    copy_file(
                        source_category / folder / asset_name,
                        output_category / folder / asset_name,
                    )
                copied_people.add(image_name)

            for image_asset in (image_name, garment_name):
                if image_asset not in copied_images:
                    copy_file(
                        source_category / "images" / image_asset,
                        output_category / "images" / image_asset,
                    )
                    copied_images.add(image_asset)

    caption_lines = []
    for garment_name in sorted(selected_garments):
        caption = captions.get(garment_name, args.category.replace("_", " "))
        caption_lines.append(f"{garment_name} {caption}\n")
    (output_category / "dc_caption.txt").write_text("".join(caption_lines), encoding="ascii")

    print(f"Subset created: {output_category}")
    print(f"Pair rows per file: {args.count}")
    print(f"People copied: {len(copied_people)}")
    print(f"Images copied: {len(copied_images)}")
    print(f"Captions written: {len(caption_lines)}")


if __name__ == "__main__":
    main()
