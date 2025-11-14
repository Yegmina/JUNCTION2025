from fastapi import FastAPI, HTTPException, UploadFile, File, Form
from typing import Optional
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

# Load environment variables
load_dotenv()

# Initialize OpenAI client
# Only pass api_key explicitly to avoid any proxy or other parameter conflicts
api_key = os.getenv("OPENAI_API_KEY")
if not api_key:
    raise ValueError("OPENAI_API_KEY environment variable is not set")
client = OpenAI(api_key=api_key)

# Global variables for FAISS index and metadata
faiss_index = None
faiss_metadata = []
EMBEDDING_DIM = 1536  # text-embedding-3-small dimension
FAISS_INDEX_FILE = "faiss_index.bin"
FAISS_METADATA_FILE = "faiss_metadata.pkl"


def get_indexed_image_paths():
    """Get list of image paths already in the index."""
    return [item.get("image_path", "") for item in faiss_metadata]


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
            faiss_index = faiss.IndexFlatL2(EMBEDDING_DIM)
            faiss_metadata = []
    else:
        # Create new index
        faiss_index = faiss.IndexFlatL2(EMBEDDING_DIM)
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


async def get_image_description_from_bytes(image_bytes: bytes) -> str:
    """Get image description using OpenAI Vision API from image bytes."""
    try:
        # Load prompt from file
        prompt_file = "prompt.txt"
        if os.path.exists(prompt_file):
            with open(prompt_file, "r", encoding="utf-8") as f:
                system_prompt = f.read().strip()
        else:
            system_prompt = "You are a food analysis assistant. Describe the food in the image objectively, focusing on ingredients, preparation style, and dish type."

        # Open image from bytes
        image = Image.open(BytesIO(image_bytes))

        # Convert to base64 for API
        buffered = BytesIO()
        # Preserve original format or convert to PNG
        if image.format:
            image.save(buffered, format=image.format)
        else:
            image.save(buffered, format="PNG")
        image_base64 = base64.b64encode(buffered.getvalue()).decode()

        # Determine MIME type
        mime_type = image.format.lower() if image.format else "png"
        if mime_type == "jpeg":
            mime_type = "jpg"

        # Call OpenAI Vision API
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
                            "text": "Analyze this image and describe the food according to the instructions.",
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
    """Add an image to the FAISS index by describing it and embedding the description."""
    global faiss_index, faiss_metadata

    try:
        # Check if image already exists
        if image_path and image_path in get_indexed_image_paths():
            return {
                "success": False,
                "message": "Image already in index",
                "image_path": image_path,
                "index_size": faiss_index.ntotal,
            }

        # Get image description
        description = await get_image_description_from_bytes(image_bytes)

        # Get embedding for description
        embedding = await get_embedding(description)

        # Reshape for FAISS (needs to be 2D array)
        embedding = embedding.reshape(1, -1)

        # Add to FAISS index
        faiss_index.add(embedding)

        # Store metadata
        faiss_metadata.append(
            {"image_path": image_path or "uploaded", "description": description}
        )

        return {
            "success": True,
            "message": "Image added to index",
            "image_path": image_path or "uploaded",
            "description": description,
            "index_size": faiss_index.ntotal,
        }
    except Exception as e:
        raise Exception(f"Error adding image to index: {str(e)}")


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

        # Search in FAISS
        distances, indices = faiss_index.search(
            query_embedding, min(top_k, faiss_index.ntotal)
        )

        # Convert distances to similarity percentages
        # Using formula: similarity = 1 / (1 + distance) * 100
        results = []
        for i, (distance, idx) in enumerate(zip(distances[0], indices[0])):
            if idx < len(faiss_metadata):
                similarity = (1 / (1 + distance)) * 100
                results.append(
                    {
                        "rank": i + 1,
                        "image_path": faiss_metadata[idx]["image_path"],
                        "description": faiss_metadata[idx]["description"],
                        "similarity_percentage": round(similarity, 2),
                        "distance": float(distance),
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
