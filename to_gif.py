import os
import sys
import argparse
from pathlib import Path

try:
    from ultralytics import YOLO
    import cv2
    import numpy as np
except ImportError as e:
    print("❌ Error: Required packages not installed")
    print(f"   Missing: {e}")
    print("   Install with: pip install ultralytics opencv-python")
    sys.exit(1)


def process_video_with_yolo(
    video_path: str,
    output_path: str,
    model_name: str = "yolov8n.pt",
    conf_threshold: float = 0.25,
):
    """
    Process a video file frame by frame with YOLO object detection.
    Creates a new video with all detected objects highlighted.

    Args:
        video_path: Path to input video file
        output_path: Path to output video file
        model_name: YOLO model to use (default: yolov8n.pt)
        conf_threshold: Confidence threshold for detections (default: 0.25)
    """
    if not os.path.exists(video_path):
        print(f"❌ Error: Video file not found: {video_path}")
        return False

    # Load YOLO model
    print(f"Loading YOLO model: {model_name}...")
    try:
        model = YOLO(model_name)
        print("✅ Model loaded successfully")
    except Exception as e:
        print(f"❌ Error loading YOLO model: {e}")
        print("   The model will be downloaded automatically on first use")
        return False

    # Open input video
    print(f"\nOpening video: {video_path}")
    cap = cv2.VideoCapture(video_path)

    if not cap.isOpened():
        print(f"❌ Error: Could not open video file: {video_path}")
        return False

    # Get video properties
    fps = int(cap.get(cv2.CAP_PROP_FPS))
    width = int(cap.get(cv2.CAP_PROP_FRAME_WIDTH))
    height = int(cap.get(cv2.CAP_PROP_FRAME_HEIGHT))
    total_frames = int(cap.get(cv2.CAP_PROP_FRAME_COUNT))

    print(f"  Resolution: {width}x{height}")
    print(f"  FPS: {fps}")
    print(f"  Total frames: {total_frames}")

    # Define codec and create VideoWriter
    fourcc = cv2.VideoWriter_fourcc(*"mp4v")
    out = cv2.VideoWriter(output_path, fourcc, fps, (width, height))

    if not out.isOpened():
        print(f"❌ Error: Could not create output video file: {output_path}")
        cap.release()
        return False

    print(f"\nProcessing frames...")
    frame_count = 0

    try:
        while True:
            ret, frame = cap.read()
            if not ret:
                break

            frame_count += 1

            # Run YOLO detection on frame
            results = model(frame, conf=conf_threshold, verbose=False)

            # Get annotated frame with all detections highlighted
            annotated_frame = results[0].plot()

            # Write annotated frame to output video
            out.write(annotated_frame)

            # Progress indicator
            if frame_count % 30 == 0 or frame_count == total_frames:
                progress = (frame_count / total_frames) * 100 if total_frames > 0 else 0
                print(f"  Processed {frame_count}/{total_frames} frames ({progress:.1f}%)")

    except KeyboardInterrupt:
        print("\n⚠️  Processing interrupted by user")
        return False
    except Exception as e:
        print(f"\n❌ Error processing video: {e}")
        return False
    finally:
        # Release everything
        cap.release()
        out.release()
        print(f"\n✅ Successfully processed {frame_count} frames")
        print(f"   Output saved to: {output_path}")

    return True


def main():
    """Main function."""
    parser = argparse.ArgumentParser(
        description="Process video with YOLO object detection and create annotated video",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  python3 to_gif.py video.mp4 output.mp4
  python3 to_gif.py video.mp4 output.mp4 --model yolov8s.pt
  python3 to_gif.py video.mp4 output.mp4 --conf 0.5
        """,
    )
    parser.add_argument(
        "input_video",
        help="Path to input video file",
    )
    parser.add_argument(
        "output_video",
        help="Path to output video file",
    )
    parser.add_argument(
        "--model",
        "-m",
        default="yolov8n.pt",
        help="YOLO model to use (default: yolov8n.pt). Options: yolov8n.pt, yolov8s.pt, yolov8m.pt, yolov8l.pt, yolov8x.pt",
    )
    parser.add_argument(
        "--conf",
        "-c",
        type=float,
        default=0.25,
        help="Confidence threshold for detections (default: 0.25)",
    )

    args = parser.parse_args()

    success = process_video_with_yolo(
        args.input_video, args.output_video, args.model, args.conf
    )

    if not success:
        sys.exit(1)


if __name__ == "__main__":
    main()

