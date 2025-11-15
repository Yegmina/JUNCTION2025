#!/usr/bin/env python3
"""
Test script for video analysis endpoint.
Usage: py test_video_analysis.py [video_file_path]
"""

import sys
import requests
import json
from pathlib import Path

SERVER_URL = "http://localhost:8000"
ENDPOINT = f"{SERVER_URL}/analyze-video"


def test_video_analysis(video_path: str):
    """Test the video analysis endpoint with a video file."""
    print(f"Testing video analysis endpoint: {ENDPOINT}")
    print(f"Video file: {video_path}")
    print("-" * 60)
    
    # Check if file exists
    if not Path(video_path).exists():
        print(f"❌ Error: Video file not found: {video_path}")
        return False
    
    try:
        # Upload and analyze video
        with open(video_path, "rb") as f:
            files = {"file": (Path(video_path).name, f, "video/mp4")}
            response = requests.post(ENDPOINT, files=files, timeout=300)  # 5 min timeout
        
        if response.status_code == 200:
            result = response.json()
            
            print("✅ Success! Video analysis completed.")
            print("\n" + "=" * 60)
            print("RESULTS SUMMARY")
            print("=" * 60)
            
            # Summary
            summary = result.get("summary", {})
            print(f"\n📊 Summary:")
            print(f"   Frames analyzed: {summary.get('frames_analyzed', 0)}")
            print(f"   Has audio transcription: {summary.get('has_audio_transcription', False)}")
            
            # Frame analysis
            frame_analysis = result.get("frame_analysis", [])
            if frame_analysis:
                print(f"\n🎬 Frame Analysis ({len(frame_analysis)} frames):")
                for i, frame in enumerate(frame_analysis, 1):
                    print(f"\n   Frame {i} (t={frame.get('timestamp', 0)}s):")
                    desc = frame.get("description", "")
                    # Show first 200 chars of description
                    if len(desc) > 200:
                        print(f"   {desc[:200]}...")
                    else:
                        print(f"   {desc}")
            
            # Audio transcription
            audio_transcription = result.get("audio_transcription", {})
            if audio_transcription:
                transcription_text = audio_transcription.get("text", "")
                if transcription_text:
                    print(f"\n🎤 Audio Transcription:")
                    print(f"   {transcription_text}")
                    
                    words = audio_transcription.get("words", [])
                    if words:
                        print(f"\n   Word count: {len([w for w in words if w.get('type') == 'word'])}")
                else:
                    error = audio_transcription.get("error")
                    if error:
                        print(f"\n⚠️  Audio transcription error: {error}")
                    else:
                        print(f"\n⚠️  No audio transcription available")
            else:
                print(f"\n⚠️  No audio transcription data")
            
            # Save full result to JSON file
            output_file = f"{Path(video_path).stem}_analysis_result.json"
            with open(output_file, "w", encoding="utf-8") as f:
                json.dump(result, f, indent=2, ensure_ascii=False)
            print(f"\n💾 Full results saved to: {output_file}")
            
            return True
        else:
            print(f"❌ Error: HTTP {response.status_code}")
            print(f"Response: {response.text}")
            return False
            
    except requests.exceptions.ConnectionError:
        print(f"❌ Error: Could not connect to server at {SERVER_URL}")
        print("   Make sure the FastAPI server is running!")
        return False
    except Exception as e:
        print(f"❌ Error: {e}")
        return False


def check_server():
    """Check if the server is running."""
    try:
        response = requests.get(f"{SERVER_URL}/index-stats", timeout=5)
        return response.status_code == 200
    except:
        return False


if __name__ == "__main__":
    # Check server
    print("Checking if server is running...")
    if not check_server():
        print(f"❌ Server is not running at {SERVER_URL}")
        print("\nPlease start the server first:")
        print("   py -m uvicorn main:app --reload --host 0.0.0.0 --port 8000")
        sys.exit(1)
    
    print("✅ Server is running!\n")
    
    # Get video file path
    if len(sys.argv) > 1:
        video_path = sys.argv[1]
    else:
        # Try to find a video file in current directory
        video_files = list(Path(".").glob("*.mp4"))
        if video_files:
            video_path = str(video_files[0])
            print(f"Using first video file found: {video_path}\n")
        else:
            print("Usage: py test_video_analysis.py [video_file_path]")
            print("\nOr place a .mp4 file in the current directory.")
            sys.exit(1)
    
    # Run test
    success = test_video_analysis(video_path)
    sys.exit(0 if success else 1)

