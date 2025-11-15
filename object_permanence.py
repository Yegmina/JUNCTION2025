import os
import sys
import argparse
import csv
from pathlib import Path
from collections import defaultdict

try:
    from ultralytics import YOLO
    from PIL import Image
except ImportError:
    print("❌ Error: ultralytics package not installed")
    print("   Install it with: pip install ultralytics")
    sys.exit(1)


def detect_objects_in_image(
    model, image_path: str, save_annotated: bool = False, output_path: str = None
) -> dict:
    """
    Run YOLO object detection on a single image.
    Returns a dictionary with object category counts.

    Args:
        model: YOLO model instance
        image_path: Path to input image
        save_annotated: Whether to save annotated image
        output_path: Path to save annotated image (if save_annotated is True)
    """
    try:
        results = model(image_path, verbose=False)

        # Count objects by category
        object_counts = defaultdict(int)

        for result in results:
            # Get detected objects
            boxes = result.boxes
            if boxes is not None:
                for box in boxes:
                    # Get class name
                    class_id = int(box.cls[0])
                    class_name = model.names[class_id]
                    object_counts[class_name] += 1

            # Save annotated image if requested
            if save_annotated and output_path:
                annotated_img = (
                    result.plot()
                )  # Creates annotated image with boxes and labels
                Image.fromarray(annotated_img).save(output_path)

        return dict(object_counts)
    except Exception as e:
        print(f"⚠️  Error processing {image_path}: {e}")
        return {}


def process_images(
    input_dir: str,
    output_csv: str,
    model_name: str = "yolov8n.pt",
    output_dir: str = "export2",
):
    """
    Process all images in input_dir and create CSV with object counts.

    Args:
        input_dir: Directory containing images
        output_csv: Output CSV file path
        model_name: YOLO model to use (default: yolov8n.pt for nano model)
        output_dir: Directory to save annotated images (default: export2)
    """
    input_path = Path(input_dir)

    if not input_path.exists():
        print(f"❌ Error: Input directory not found: {input_dir}")
        return False

    # Find all image files
    image_extensions = {".jpg", ".jpeg", ".png", ".bmp", ".tiff", ".webp"}
    image_files = [
        f
        for f in input_path.iterdir()
        if f.is_file() and f.suffix.lower() in image_extensions
    ]

    if not image_files:
        print(f"⚠️  No image files found in {input_dir}")
        return False

    image_files.sort()
    print(f"Found {len(image_files)} image(s) to process")

    # Load YOLO model
    print(f"Loading YOLO model: {model_name}...")
    try:
        model = YOLO(model_name)
        print("✅ Model loaded successfully")
    except Exception as e:
        print(f"❌ Error loading YOLO model: {e}")
        print("   The model will be downloaded automatically on first use")
        return False

    # Create output directory for annotated images
    output_path = Path(output_dir)
    output_path.mkdir(parents=True, exist_ok=True)
    print(f"Annotated images will be saved to: {output_dir}/")

    # Process all images and collect object counts
    all_results = []
    all_categories = set()

    print("\nProcessing images...")
    for i, image_file in enumerate(image_files, 1):
        print(f"  [{i}/{len(image_files)}] Processing: {image_file.name}")

        # Prepare output path for annotated image
        annotated_output = output_path / image_file.name

        # Detect objects and save annotated image
        object_counts = detect_objects_in_image(
            model,
            str(image_file),
            save_annotated=True,
            output_path=str(annotated_output),
        )

        # Store results with image filename
        result_row = {"image": image_file.name}
        result_row.update(object_counts)
        all_results.append(result_row)

        # Track all unique categories
        all_categories.update(object_counts.keys())

    # Sort categories for consistent column order
    sorted_categories = sorted(all_categories)

    # Write CSV file
    print(f"\nWriting results to: {output_csv}")
    try:
        with open(output_csv, "w", newline="", encoding="utf-8") as csvfile:
            # Define columns: image name + all categories
            fieldnames = ["image"] + sorted_categories

            writer = csv.DictWriter(csvfile, fieldnames=fieldnames)
            writer.writeheader()

            # Write each row
            for result_row in all_results:
                # Ensure all categories are present (fill with 0 if missing)
                row = {"image": result_row["image"]}
                for category in sorted_categories:
                    row[category] = result_row.get(category, 0)
                writer.writerow(row)

        print(
            f"✅ Successfully created CSV with {len(all_results)} row(s) and {len(sorted_categories)} category columns"
        )
        print(f"   Categories detected: {', '.join(sorted_categories)}")
        print(
            f"✅ Successfully saved {len(image_files)} annotated image(s) to: {output_dir}/"
        )
        return True

    except Exception as e:
        print(f"❌ Error writing CSV file: {e}")
        return False


def main():
    """Main function."""
    parser = argparse.ArgumentParser(
        description="Run YOLO object detection on images and output CSV with object counts",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  python3 object_permanence.py
  python3 object_permanence.py --input-dir exports --output-csv results.csv
  python3 object_permanence.py --model yolov8s.pt --output-dir export2
        """,
    )
    parser.add_argument(
        "--input-dir",
        "-i",
        default="exports",
        help="Input directory containing images (default: exports)",
    )
    parser.add_argument(
        "--output-csv",
        "-o",
        default="object_counts.csv",
        help="Output CSV file path (default: object_counts.csv)",
    )
    parser.add_argument(
        "--model",
        "-m",
        default="yolov8n.pt",
        help="YOLO model to use (default: yolov8n.pt). Options: yolov8n.pt, yolov8s.pt, yolov8m.pt, yolov8l.pt, yolov8x.pt",
    )
    parser.add_argument(
        "--output-dir",
        "-d",
        default="export2",
        help="Output directory for annotated images (default: export2)",
    )

    args = parser.parse_args()

    success = process_images(
        args.input_dir, args.output_csv, args.model, args.output_dir
    )

    if not success:
        sys.exit(1)


if __name__ == "__main__":
    main()
