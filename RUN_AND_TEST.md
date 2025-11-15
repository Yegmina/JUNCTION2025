# How to Run and Test Video Analysis

## Prerequisites

1. **Python 3.8+** installed
2. **ffmpeg** installed and in PATH (required for audio extraction)
   - Download from: https://ffmpeg.org/download.html
   - Or install via: `choco install ffmpeg` (if you have Chocolatey)

## Step 1: Set Up Environment

### Create Virtual Environment (Windows PowerShell)

```powershell
# Create virtual environment
python -m venv venv

# Activate virtual environment
.\venv\Scripts\Activate.ps1
```

If you get an execution policy error, run:
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### Install Dependencies

```powershell
# Upgrade pip
python -m pip install --upgrade pip setuptools wheel

# Install dependencies
pip install -r requirements.txt
```

## Step 2: Configure Environment Variables

1. Copy `env.example.txt` to `.env`:
   ```powershell
   Copy-Item env.example.txt .env
   ```

2. Edit `.env` and add your API keys:
   ```
   OPENAI_API_KEY=sk-your-openai-key-here
   ELEVENLABS_API_KEY=your-elevenlabs-key-here
   ```

   - **OPENAI_API_KEY**: Required - Get from https://platform.openai.com/api-keys
   - **ELEVENLABS_API_KEY**: Optional - Get from https://elevenlabs.io/app/settings/api-keys
     - If not set, video analysis will work but audio transcription will be skipped

## Step 3: Run the Server

```powershell
# Make sure virtual environment is activated
.\venv\Scripts\Activate.ps1

# Run the FastAPI server
python -m uvicorn main:app --reload --host 0.0.0.0 --port 8000
```

The server will start at: **http://localhost:8000**

You can also visit **http://localhost:8000/docs** for interactive API documentation.

## Step 4: Test Video Analysis

### Option 1: Using the Test Script (Recommended)

```powershell
# In a new terminal (keep server running in the first terminal)
.\venv\Scripts\Activate.ps1
python test_video_analysis.py burger.mp4
```

Or test with any video file:
```powershell
python test_video_analysis.py path/to/your/video.mp4
```

### Option 2: Using curl (PowerShell)

```powershell
curl -X POST "http://localhost:8000/analyze-video" `
  -F "file=@burger.mp4" `
  -o result.json

# View results
Get-Content result.json | ConvertFrom-Json | ConvertTo-Json -Depth 10
```

### Option 3: Using Python Requests

```python
import requests

with open("burger.mp4", "rb") as f:
    files = {"file": ("burger.mp4", f, "video/mp4")}
    response = requests.post("http://localhost:8000/analyze-video", files=files)
    print(response.json())
```

### Option 4: Using the Interactive API Docs

1. Open http://localhost:8000/docs in your browser
2. Find the `/analyze-video` endpoint
3. Click "Try it out"
4. Upload a video file
5. Click "Execute"
6. View the results

## Expected Response

The API returns a JSON response with:

```json
{
  "video_filename": "burger.mp4",
  "frame_analysis": [
    {
      "frame_index": 0,
      "timestamp": 0.0,
      "description": "Detailed food description..."
    },
    ...
  ],
  "audio_transcription": {
    "text": "Transcribed audio text...",
    "words": [...],
    "language": "en"
  },
  "summary": {
    "frames_analyzed": 5,
    "has_audio_transcription": true,
    "transcription_text": "Transcribed audio text..."
  }
}
```

## Troubleshooting

### Server won't start
- Make sure port 8000 is not in use
- Check that all dependencies are installed
- Verify Python version is 3.8+

### ffmpeg not found
- Install ffmpeg and add it to your PATH
- Test with: `ffmpeg -version`

### API Key errors
- Verify `.env` file exists and has correct keys
- Check that keys are not wrapped in quotes
- For OpenAI: Make sure key starts with `sk-`
- For ElevenLabs: Make sure key is valid

### Audio transcription fails
- Check ElevenLabs API key is set
- Verify you have credits/quota available
- Check API key permissions

### Video processing is slow
- Large videos take longer to process
- Frame analysis uses OpenAI API (may have rate limits)
- Audio transcription depends on video length

## Quick Test Commands

```powershell
# Check server is running
curl http://localhost:8000/index-stats

# Test with burger video (if available)
python test_video_analysis.py burger.mp4

# Test with any video
python test_video_analysis.py path/to/video.mp4
```


