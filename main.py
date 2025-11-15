from fastapi import FastAPI, HTTPException, UploadFile, File, Form
from typing import Optional, List, Dict
from openai import OpenAI
import os
import faiss
import numpy as np
import pickle
from contextlib import asynccontextmanager
from dotenv import load_dotenv
from io import BytesIO
from PIL import Image
import base64
import cv2
import subprocess
import tempfile
import requests
import time
from pathlib import Path

# Load environment variables
load_dotenv()

# Initialize OpenAI client
# Only pass api_key explicitly to avoid any proxy or other parameter conflicts
api_key = os.getenv("OPENAI_API_KEY")
if not api_key:
    raise ValueError("OPENAI_API_KEY environment variable is not set")
client = OpenAI(api_key=api_key)

# Initialize ElevenLabs API key
elevenlabs_api_key = os.getenv("ELEVENLABS_API_KEY")
if not elevenlabs_api_key:
    print("Warning: ELEVENLABS_API_KEY not set. Audio transcription will not work.")

# Global variables for FAISS index and metadata
faiss_index = None
faiss_metadata = []
EMBEDDING_DIM = 1536  # text-embedding-3-small dimension
FAISS_INDEX_FILE = "faiss_index.bin"
FAISS_METADATA_FILE = "faiss_metadata.pkl"


def get_indexed_image_paths():
    """Get list of image paths already in the index."""
    return [item.get("image_path", "") for item in faiss_metadata]


def get_indexed_image_indices():
    """Get set of image indices already in the index."""
    return {item.get("image_index") for item in faiss_metadata if "image_index" in item}


@asynccontextmanager
async def lifespan(app: FastAPI):
    # Startup: Load FAISS index and metadata
    global faiss_index, faiss_metadata

    if os.path.exists(FAISS_INDEX_FILE) and os.path.exists(FAISS_METADATA_FILE):
        try:
            # Load FAISS index
            faiss_index = faiss.read_index(FAISS_INDEX_FILE)
            # Load metadata
            with open(FAISS_METADATA_FILE, "rb") as f:
                faiss_metadata = pickle.load(f)
            print(f"Loaded FAISS index with {faiss_index.ntotal} vectors")
        except Exception as e:
            print(f"Error loading FAISS index: {e}. Creating new index.")
            faiss_index = faiss.IndexFlatIP(EMBEDDING_DIM)
            faiss_metadata = []
    else:
        # Create new index
        faiss_index = faiss.IndexFlatIP(EMBEDDING_DIM)
        faiss_metadata = []
        print("Created new FAISS index")

    yield

    # Shutdown: Save FAISS index and metadata
    if faiss_index is not None and faiss_index.ntotal > 0:
        try:
            faiss.write_index(faiss_index, FAISS_INDEX_FILE)
            with open(FAISS_METADATA_FILE, "wb") as f:
                pickle.dump(faiss_metadata, f)
            print(f"Saved FAISS index with {faiss_index.ntotal} vectors")
        except Exception as e:
            print(f"Error saving FAISS index: {e}")


app = FastAPI(title="Image Description API", lifespan=lifespan)


def parse_index_from_filename(filename: str) -> Optional[int]:
    """Extract index number from filename (number before underscore)."""
    if not filename:
        return None
    basename = os.path.basename(filename)
    if "_" in basename:
        index_part = basename.split("_")[0]
        try:
            return int(index_part)
        except ValueError:
            return None
    return None


async def get_image_description_from_bytes(
    image_bytes: bytes, variation: int = 0
) -> str:
    """Get image description using OpenAI Vision API from image bytes.

    Args:
        image_bytes: The image bytes
        variation: Variation number (0-4) to generate different descriptions
    """
    try:
        # Load prompt from file
        prompt_file = "prompt.txt"
        if os.path.exists(prompt_file):
            with open(prompt_file, "r", encoding="utf-8") as f:
                system_prompt = f.read().strip()
        else:
            system_prompt = "You are a food analysis assistant. Describe the food in the image objectively, focusing on ingredients, preparation style, and dish type."

        image = Image.open(BytesIO(image_bytes))

        buffered = BytesIO()
        if image.format:
            image.save(buffered, format=image.format)
        else:
            image.save(buffered, format="PNG")
        image_base64 = base64.b64encode(buffered.getvalue()).decode()

        mime_type = image.format.lower() if image.format else "png"
        if mime_type == "jpeg":
            mime_type = "jpg"

        # Add variation instruction to get different descriptions
        user_prompt = (
            "Analyze this image and describe the food according to the instructions."
        )
        if variation > 0:
            user_prompt += f" Provide a different perspective or emphasis on this description (variation {variation + 1})."

        response = client.chat.completions.create(
            model="gpt-4o",
            messages=[
                {
                    "role": "system",
                    "content": system_prompt,
                },
                {
                    "role": "user",
                    "content": [
                        {
                            "type": "text",
                            "text": user_prompt,
                        },
                        {
                            "type": "image_url",
                            "image_url": {
                                "url": f"data:image/{mime_type};base64,{image_base64}"
                            },
                        },
                    ],
                },
            ],
            max_tokens=500,
            temperature=0,
        )

        description = response.choices[0].message.content.strip()
        return description
    except Exception as e:
        raise Exception(f"Error getting image description: {str(e)}")


async def get_embedding(text: str) -> np.ndarray:
    """Get embedding for text using OpenAI embeddings API."""
    try:
        response = client.embeddings.create(model="text-embedding-3-small", input=text)
        embedding = np.array(response.data[0].embedding, dtype=np.float32)
        return embedding
    except Exception as e:
        raise Exception(f"Error getting embedding: {str(e)}")


async def add_image_to_index(image_bytes: bytes, image_path: str = None) -> dict:
    """Add an image to the FAISS index by generating 5 descriptions and embedding each separately."""
    global faiss_index, faiss_metadata

    try:
        # Parse index from filename
        image_index = parse_index_from_filename(image_path) if image_path else None

        # Check if image with this index already exists
        if image_index is not None:
            indexed_indices = get_indexed_image_indices()
            if image_index in indexed_indices:
                return {
                    "success": False,
                    "message": f"Image with index {image_index} already in index",
                    "image_path": image_path,
                    "image_index": image_index,
                    "index_size": faiss_index.ntotal,
                }

        # Generate 5 different descriptions
        descriptions = []
        for i in range(5):
            description = await get_image_description_from_bytes(
                image_bytes, variation=i
            )
            descriptions.append(description)

        # Add each description separately to the index
        added_count = 0
        for i, description in enumerate(descriptions):
            # Get embedding for description
            embedding = await get_embedding(description)

            # Reshape for FAISS (needs to be 2D array)
            embedding = embedding.reshape(1, -1)

            # Normalize for cosine similarity (L2 normalization)
            faiss.normalize_L2(embedding)

            # Add to FAISS index
            faiss_index.add(embedding)

            # Store metadata with index number
            metadata_entry = {
                "image_path": image_path or "uploaded",
                "description": description,
                "description_variation": i + 1,
            }
            if image_index is not None:
                metadata_entry["image_index"] = image_index

            faiss_metadata.append(metadata_entry)
            added_count += 1

        return {
            "success": True,
            "message": f"Image added to index with {added_count} descriptions",
            "image_path": image_path or "uploaded",
            "image_index": image_index,
            "descriptions_count": added_count,
            "index_size": faiss_index.ntotal,
        }
    except Exception as e:
        raise Exception(f"Error adding image to index: {str(e)}")


async def extract_audio_from_video(video_bytes: bytes) -> bytes:
    """Extract audio from video using ffmpeg.
    
    Args:
        video_bytes: The video file bytes
        
    Returns:
        Audio bytes in WAV format
    """
    with tempfile.NamedTemporaryFile(delete=False, suffix='.mp4') as video_file:
        video_file.write(video_bytes)
        video_path = video_file.name
    
    try:
        with tempfile.NamedTemporaryFile(delete=False, suffix='.wav') as audio_file:
            audio_path = audio_file.name
        
        # Extract audio using ffmpeg
        cmd = [
            "ffmpeg",
            "-i", video_path,
            "-vn",  # No video
            "-acodec", "pcm_s16le",  # PCM 16-bit little-endian
            "-ar", "44100",  # Sample rate
            "-ac", "2",  # Stereo
            "-y",  # Overwrite output
            audio_path
        ]
        
        result = subprocess.run(
            cmd,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True
        )
        
        if result.returncode != 0:
            raise Exception(f"ffmpeg error: {result.stderr}")
        
        # Read audio file
        with open(audio_path, "rb") as f:
            audio_bytes = f.read()
        
        return audio_bytes
    finally:
        # Clean up temporary files
        try:
            os.unlink(video_path)
            os.unlink(audio_path)
        except:
            pass


async def transcribe_audio_with_elevenlabs(audio_bytes: bytes, max_retries: int = 3, base_delay: float = 2.0) -> Dict:
    """Transcribe audio using ElevenLabs Speech-to-Text API with retry logic.
    
    Args:
        audio_bytes: Audio file bytes (WAV format)
        max_retries: Maximum number of retry attempts for rate-limited requests
        base_delay: Base delay in seconds for exponential backoff
        
    Returns:
        Dictionary with transcription results including text and word timestamps
    """
    if not elevenlabs_api_key:
        raise Exception("ElevenLabs API key not configured")
    
    try:
        # Save audio to temporary file for API call
        with tempfile.NamedTemporaryFile(delete=False, suffix='.wav') as audio_file:
            audio_file.write(audio_bytes)
            audio_path = audio_file.name
        
        try:
            # Call ElevenLabs STT API using REST API with retry logic
            url = "https://api.elevenlabs.io/v1/speech-to-text"
            headers = {
                "xi-api-key": elevenlabs_api_key
            }
            
            last_error = None
            for attempt in range(max_retries + 1):
                try:
                    # Use 'file' parameter as required by the API
                    with open(audio_path, "rb") as f:
                        files = {
                            "file": ("audio.wav", f, "audio/wav")
                        }
                        data = {
                            "model_id": "scribe_v1"
                        }
                        
                        response = requests.post(url, headers=headers, files=files, data=data, timeout=60)
                        
                        if response.status_code == 200:
                            transcription = response.json()
                            return transcription
                        elif response.status_code == 429:
                            # Rate limited or system busy - retry with exponential backoff
                            if attempt < max_retries:
                                delay = base_delay * (2 ** attempt)
                                error_msg = response.json().get("detail", {}).get("message", "Rate limit exceeded")
                                print(f"  ⏳ {error_msg} - Retrying in {delay:.1f}s (attempt {attempt + 1}/{max_retries})...")
                                time.sleep(delay)
                                continue
                            else:
                                raise Exception(f"ElevenLabs API rate limited after {max_retries} retries: {response.text}")
                        else:
                            raise Exception(f"ElevenLabs API error: {response.status_code} - {response.text}")
                            
                except requests.exceptions.RequestException as e:
                    last_error = e
                    if attempt < max_retries:
                        delay = base_delay * (2 ** attempt)
                        print(f"  ⏳ Request error: {e} - Retrying in {delay:.1f}s (attempt {attempt + 1}/{max_retries})...")
                        time.sleep(delay)
                        continue
                    else:
                        raise Exception(f"Network error after {max_retries} retries: {str(e)}")
            
            if last_error:
                raise last_error
                
        finally:
            try:
                os.unlink(audio_path)
            except:
                pass
    except Exception as e:
        raise Exception(f"Error transcribing audio: {str(e)}")


async def analyze_video_frames(video_bytes: bytes, num_frames: int = 5) -> List[Dict]:
    """Extract and analyze key frames from video.
    
    Args:
        video_bytes: The video file bytes
        num_frames: Number of frames to extract and analyze
        
    Returns:
        List of dictionaries with frame descriptions
    """
    with tempfile.NamedTemporaryFile(delete=False, suffix='.mp4') as video_file:
        video_file.write(video_bytes)
        video_path = video_file.name
    
    try:
        # Open video with OpenCV
        cap = cv2.VideoCapture(video_path)
        if not cap.isOpened():
            raise Exception("Could not open video file")
        
        # Get video properties
        total_frames = int(cap.get(cv2.CAP_PROP_FRAME_COUNT))
        fps = cap.get(cv2.CAP_PROP_FPS)
        duration = total_frames / fps if fps > 0 else 0
        
        print(f"  Video info: {total_frames} frames, {fps:.2f} fps, {duration:.2f}s duration")
        
        # Calculate frame indices to extract (evenly spaced)
        frame_indices = []
        if total_frames > 0:
            step = max(1, total_frames // num_frames)
            frame_indices = [i * step for i in range(min(num_frames, total_frames))]
        
        print(f"  Analyzing {len(frame_indices)} frames...")
        
        frame_descriptions = []
        for i, frame_idx in enumerate(frame_indices, 1):
            cap.set(cv2.CAP_PROP_POS_FRAMES, frame_idx)
            ret, frame = cap.read()
            
            if not ret:
                continue
            
            # Convert frame to image bytes
            _, buffer = cv2.imencode('.jpg', frame)
            frame_bytes = buffer.tobytes()
            
            # Get description using OpenAI Vision API
            try:
                print(f"  Frame {i}/{len(frame_indices)} (t={frame_idx/fps:.2f}s)...", end=" ", flush=True)
                description = await get_image_description_from_bytes(frame_bytes)
                timestamp = frame_idx / fps if fps > 0 else 0
                
                frame_descriptions.append({
                    "frame_index": frame_idx,
                    "timestamp": round(timestamp, 2),
                    "description": description
                })
                print("✓")
            except Exception as e:
                print(f"✗ Error: {e}")
        
        cap.release()
        return frame_descriptions
    finally:
        try:
            os.unlink(video_path)
        except:
            pass


async def search_similar_images(image_bytes: bytes, top_k: int = 5) -> dict:
    """Search for similar images in FAISS index."""
    global faiss_index, faiss_metadata

    if faiss_index is None or faiss_index.ntotal == 0:
        raise HTTPException(
            status_code=400, detail="FAISS index is empty. Add images first."
        )

    try:
        # Get image description
        description = await get_image_description_from_bytes(image_bytes)

        # Get embedding for description
        query_embedding = await get_embedding(description)

        # Reshape for FAISS (needs to be 2D array)
        query_embedding = query_embedding.reshape(1, -1)

        # Normalize for cosine similarity (L2 normalization)
        faiss.normalize_L2(query_embedding)

        # Search in FAISS
        # For IndexFlatIP, returns inner product (cosine similarity for normalized vectors)
        # Higher values = more similar (range: -1 to 1, typically 0 to 1 for embeddings)
        similarities, indices = faiss_index.search(
            query_embedding, min(top_k, faiss_index.ntotal)
        )

        # Convert inner product (cosine similarity) to percentage
        # Cosine similarity ranges from -1 to 1, but embeddings are typically 0 to 1
        # Convert to percentage: (similarity + 1) / 2 * 100 for full range, or just similarity * 100 for 0-1 range
        results = []
        for i, (similarity, idx) in enumerate(zip(similarities[0], indices[0])):
            if idx < len(faiss_metadata):
                # Convert cosine similarity (0-1 range) to percentage
                similarity_percentage = similarity * 100
                results.append(
                    {
                        "rank": i + 1,
                        "image_path": faiss_metadata[idx]["image_path"],
                        "description": faiss_metadata[idx]["description"],
                        "similarity_percentage": round(similarity_percentage, 2),
                        "cosine_similarity": float(similarity),
                    }
                )

        return {
            "query_description": description,
            "results": results,
        }
    except Exception as e:
        raise Exception(f"Error searching similar images: {str(e)}")


@app.post("/describe-image")
async def describe_image(file: UploadFile = File(...)):
    """Describe an image from bytes."""
    try:
        image_bytes = await file.read()
        description = await get_image_description_from_bytes(image_bytes)
        return {"description": description}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@app.post("/add-image")
async def add_image(
    file: UploadFile = File(...), image_path: Optional[str] = Form(None)
):
    """Add an image to the FAISS index from bytes."""
    try:
        image_bytes = await file.read()
        result = await add_image_to_index(image_bytes, image_path)
        return result
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@app.post("/search-images")
async def search_images(file: UploadFile = File(...)):
    """Search for similar images in the FAISS index from bytes."""
    try:
        image_bytes = await file.read()
        result = await search_similar_images(image_bytes, top_k=5)
        return result
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@app.get("/index-stats")
async def get_index_stats():
    """Get statistics about the FAISS index."""
    global faiss_index, faiss_metadata
    return {
        "index_size": faiss_index.ntotal if faiss_index else 0,
        "metadata_count": len(faiss_metadata),
        "embedding_dimension": EMBEDDING_DIM,
    }


@app.get("/index-list")
async def get_index_list():
    """Get all indexed images with their descriptions."""
    global faiss_index, faiss_metadata

    if faiss_index is None or faiss_index.ntotal == 0:
        return {"total": 0, "items": []}

    items = []
    for idx, metadata in enumerate(faiss_metadata):
        items.append(
            {
                "index": idx,
                "image_path": metadata.get("image_path", "unknown"),
                "description": metadata.get("description", ""),
            }
        )

    return {"total": len(items), "items": items}


@app.post("/analyze-video")
async def analyze_video(file: UploadFile = File(...)):
    """Analyze a video file: extract frames and transcribe audio.
    
    This endpoint:
    1. Extracts key frames from the video and analyzes them using OpenAI Vision
    2. Extracts audio from the video and transcribes it using ElevenLabs STT
    3. Returns combined results with visual descriptions and audio transcription
    
    Note: Processing can take 30 seconds to several minutes depending on video length.
    """
    import time
    start_time = time.time()
    
    try:
        print(f"\n{'='*60}")
        print(f"Starting video analysis for: {file.filename}")
        print(f"{'='*60}")
        
        video_bytes = await file.read()
        video_size_mb = len(video_bytes) / (1024 * 1024)
        print(f"Video size: {video_size_mb:.2f} MB")
        
        # Analyze video frames
        print("\n[1/3] Extracting and analyzing video frames...")
        frame_start = time.time()
        frame_descriptions = await analyze_video_frames(video_bytes, num_frames=5)
        frame_time = time.time() - frame_start
        print(f"✓ Frame analysis completed in {frame_time:.1f}s ({len(frame_descriptions)} frames)")
        
        # Extract and transcribe audio
        audio_transcription = None
        transcription_text = ""
        transcription_words = []
        
        print("\n[2/3] Extracting audio from video...")
        try:
            audio_start = time.time()
            audio_bytes = await extract_audio_from_video(video_bytes)
            audio_extract_time = time.time() - audio_start
            print(f"✓ Audio extraction completed in {audio_extract_time:.1f}s")
            
            print("\n[3/3] Transcribing audio with ElevenLabs...")
            transcription_start = time.time()
            transcription_result = await transcribe_audio_with_elevenlabs(audio_bytes)
            transcription_time = time.time() - transcription_start
            print(f"✓ Audio transcription completed in {transcription_time:.1f}s")
            
            # Extract text and words from transcription
            if isinstance(transcription_result, dict):
                transcription_text = transcription_result.get("text", "")
                transcription_words = transcription_result.get("words", [])
            else:
                # Handle case where API returns different format
                transcription_text = str(transcription_result)
            
            audio_transcription = {
                "text": transcription_text,
                "words": transcription_words,
                "language": transcription_result.get("language_code", "unknown") if isinstance(transcription_result, dict) else None
            }
        except Exception as e:
            print(f"⚠ Warning: Audio transcription failed: {e}")
            audio_transcription = {
                "text": "",
                "words": [],
                "error": str(e)
            }
        
        total_time = time.time() - start_time
        print(f"\n{'='*60}")
        print(f"✓ Video analysis completed in {total_time:.1f}s total")
        print(f"{'='*60}\n")
        
        return {
            "video_filename": file.filename,
            "frame_analysis": frame_descriptions,
            "audio_transcription": audio_transcription,
            "summary": {
                "frames_analyzed": len(frame_descriptions),
                "has_audio_transcription": audio_transcription is not None and audio_transcription.get("text", "") != "",
                "transcription_text": transcription_text,
                "processing_time_seconds": round(total_time, 2)
            }
        }
    except Exception as e:
        print(f"\n❌ Error during video analysis: {e}")
        raise HTTPException(status_code=500, detail=str(e))
