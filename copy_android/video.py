import os
import sys
import subprocess
import argparse
from pathlib import Path


def check_ffmpeg():
    try:
        subprocess.run(
            ["ffmpeg", "-version"],
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            check=True,
        )
        return True
    except (subprocess.CalledProcessError, FileNotFoundError):
        return False


def extract_iframes(video_path: str, output_dir: str = "exports"):
    if not os.path.exists(video_path):
        print(f"❌ Error: Video file not found: {video_path}")
        return False

    os.makedirs(output_dir, exist_ok=True)

    video_name = Path(video_path).stem

    output_pattern = os.path.join(output_dir, f"{video_name}_iframe_%04d.jpg")

    print(f"Extracting I-frames from: {video_path}")
    print(f"Output directory: {output_dir}")

    try:
        cmd = [
            "ffmpeg",
            "-i",
            video_path,
            "-vf",
            "select='eq(pict_type,I)'",
            "-vsync",
            "vfr",
            "-frame_pts",
            "1",
            output_pattern,
            "-y",  # Overwrite output files
        ]

        result = subprocess.run(
            cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True
        )

        if result.returncode != 0:
            print(f"❌ Error running ffmpeg:")
            print(result.stderr)
            return False

        extracted_files = sorted(Path(output_dir).glob(f"{video_name}_iframe_*.jpg"))
        count = len(extracted_files)

        if count > 0:
            print(f"✅ Successfully extracted {count} I-frame(s)")
            print(f"   Saved to: {output_dir}/")
            return True
        else:
            print("⚠️  No I-frames found or extracted")
            return False

    except Exception as e:
        print(f"❌ Error extracting I-frames: {e}")
        return False


def main():
    """Main function."""
    parser = argparse.ArgumentParser(
        description="Extract all I-frames from a video file",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  python3 video.py video.mp4
  python3 video.py video.mp4 --output-dir frames
        """,
    )
    parser.add_argument("video_file", help="Path to the video file")
    parser.add_argument(
        "--output-dir",
        "-o",
        default="exports",
        help="Output directory for extracted I-frames (default: exports)",
    )

    args = parser.parse_args()

    if not check_ffmpeg():
        print("❌ Error: ffmpeg is not installed or not in PATH")
        print("   Install it with: sudo apt-get install ffmpeg")
        print("   Or: brew install ffmpeg (on macOS)")
        sys.exit(1)

    success = extract_iframes(args.video_file, args.output_dir)

    if not success:
        sys.exit(1)


if __name__ == "__main__":
    main()
