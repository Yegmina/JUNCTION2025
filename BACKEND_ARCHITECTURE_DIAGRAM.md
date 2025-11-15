# Backend Architecture: Technical Deep Dive

## 🧠 AI-Powered Backend System Architecture

```mermaid
graph TB
    subgraph "FastAPI Application Layer"
        A[FastAPI App<br/>main.py] --> B[Lifespan Manager]
        B --> C[Load FAISS Index<br/>faiss_index.bin]
        B --> D[Load Metadata<br/>faiss_metadata.pkl]
        B --> E[Initialize OpenAI Client]
        B --> F[Initialize ElevenLabs Client]
    end

    subgraph "API Endpoints"
        G[POST /describe-image] --> H[Image Description Pipeline]
        I[POST /add-image] --> J[Image Indexing Pipeline]
        K[POST /search-images] --> L[Semantic Search Pipeline]
        M[POST /analyze-video] --> N[Video Analysis Pipeline]
        O[GET /index-stats] --> P[FAISS Stats]
        Q[GET /index-list] --> R[Metadata List]
    end

    subgraph "AI Processing Core"
        H --> S[OpenAI Vision API<br/>GPT-4o]
        J --> S
        L --> S
        N --> S
        
        S --> T[Image Description<br/>1500 tokens max]
        T --> U[Text Embedding<br/>text-embedding-3-small]
        U --> V[1536-dim Vector]
        
        N --> W[Frame Extraction<br/>OpenCV]
        N --> X[Audio Extraction<br/>ffmpeg]
        X --> Y[ElevenLabs STT<br/>scribe_v1]
    end

    subgraph "Vector Database (FAISS)"
        V --> Z[FAISS IndexFlatL2<br/>L2 Distance]
        Z --> AA[Vector Storage<br/>Binary Format]
        Z --> AB[Metadata Storage<br/>Pickle Format]
        AB --> AC[image_path<br/>description<br/>description_variation<br/>image_index]
    end

    subgraph "Search & Matching"
        L --> AD[Query Embedding]
        AD --> AE[FAISS Search<br/>top_k=5]
        AE --> AF[Distance Calculation<br/>L2 → Similarity %]
        AF --> AG[Results Ranking]
    end

    A --> G
    A --> I
    A --> K
    A --> M
    A --> O
    A --> Q
```

---

## 🔬 Detailed AI Processing Pipelines

### 1. Image Description Generation Pipeline

```mermaid
sequenceDiagram
    participant Client
    participant FastAPI
    participant OpenAI_Vision
    participant Prompt_Engine
    participant Image_Processor

    Client->>FastAPI: POST /describe-image<br/>(image bytes)
    FastAPI->>Image_Processor: Load image from bytes
    Image_Processor->>Image_Processor: PIL Image.open(BytesIO)
    Image_Processor->>Image_Processor: Convert to base64
    Image_Processor->>Prompt_Engine: Load prompt.txt
    Prompt_Engine->>Prompt_Engine: Read system prompt<br/>(food analysis instructions)
    Prompt_Engine->>OpenAI_Vision: API Request<br/>model: gpt-4o<br/>messages: [system, user]<br/>content: [text, image_url]
    OpenAI_Vision->>OpenAI_Vision: Vision Analysis<br/>- Dish type & cuisine<br/>- Ingredients inventory<br/>- Preparation style<br/>- Visual characteristics<br/>- Inferred aromas/flavors
    OpenAI_Vision->>FastAPI: Response<br/>(description text, 1500 tokens)
    FastAPI->>Client: JSON {description: "..."}
```

**Technical Details:**
- **Model**: `gpt-4o` (multimodal)
- **Max Tokens**: 1500
- **Temperature**: 0 (deterministic)
- **Image Format**: Base64 encoded (JPEG/PNG)
- **MIME Type**: Auto-detected from PIL format
- **Prompt Strategy**: System prompt from `prompt.txt` + user instruction

---

### 2. Image Indexing Pipeline (5-Variation Strategy)

```mermaid
flowchart TD
    A[Upload Image] --> B[Parse Index from Filename<br/>e.g., '123_image.jpg' → 123]
    B --> C{Index Already<br/>Exists?}
    C -->|Yes| D[Return Error<br/>Skip Indexing]
    C -->|No| E[Generate 5 Descriptions]
    
    E --> F[Variation 0<br/>Base Description]
    E --> G[Variation 1<br/>Different Perspective]
    E --> H[Variation 2<br/>Alternative Emphasis]
    E --> I[Variation 3<br/>Different Focus]
    E --> J[Variation 4<br/>Unique Angle]
    
    F --> K[OpenAI Vision API]
    G --> K
    H --> K
    I --> K
    J --> K
    
    K --> L[Get Embedding<br/>text-embedding-3-small]
    L --> M[1536-dim Vector<br/>float32]
    M --> N[Reshape: 1x1536]
    N --> O[Add to FAISS Index]
    O --> P[Store Metadata<br/>- image_path<br/>- description<br/>- variation_num<br/>- image_index]
    
    P --> Q[Repeat for 5 Variations]
    Q --> R[Return Success<br/>5 embeddings added]
```

**Technical Implementation:**
```python
# Pseudo-code for indexing
for variation in range(5):
    description = await get_image_description_from_bytes(
        image_bytes, variation=variation
    )
    embedding = await get_embedding(description)  # 1536-dim
    embedding = embedding.reshape(1, -1)  # FAISS requires 2D
    faiss_index.add(embedding)
    metadata.append({
        "image_path": image_path,
        "description": description,
        "description_variation": variation + 1,
        "image_index": parsed_index
    })
```

**Why 5 Variations?**
- Increases search recall (different phrasings match different queries)
- Captures multiple semantic perspectives
- Improves matching for similar but differently described dishes

---

### 3. Semantic Search Pipeline

```mermaid
flowchart LR
    A[Query Image] --> B[Generate Description<br/>GPT-4 Vision]
    B --> C[Create Embedding<br/>text-embedding-3-small]
    C --> D[1536-dim Query Vector]
    D --> E[FAISS Search<br/>IndexFlatL2.search]
    E --> F[Calculate L2 Distances]
    F --> G[Convert to Similarity %<br/>1 / 1+distance * 100]
    G --> H[Sort by Similarity]
    H --> I[Top 5 Results]
    I --> J[Return with Metadata]
```

**Distance → Similarity Conversion:**
```python
# L2 Distance (lower = more similar)
distance = faiss_index.search(query_vector, k=5)

# Convert to similarity percentage
similarity = (1 / (1 + distance)) * 100

# Example:
# distance = 0.5  → similarity = 66.67%
# distance = 0.1  → similarity = 90.91%
# distance = 2.0  → similarity = 33.33%
```

**FAISS Index Details:**
- **Type**: `IndexFlatL2` (exact L2 distance, no approximation)
- **Dimension**: 1536 (matches embedding size)
- **Search Complexity**: O(n) where n = number of indexed vectors
- **Storage**: Binary file (`faiss_index.bin`) + Pickle metadata

---

### 4. Video Analysis Pipeline (Multi-Modal)

```mermaid
flowchart TD
    A[Upload Video] --> B[Extract Video Metadata<br/>OpenCV]
    B --> C[Total Frames<br/>FPS<br/>Duration]
    C --> D[Calculate Frame Indices<br/>Evenly Spaced]
    D --> E[Extract 5 Key Frames]
    
    E --> F[Parallel Processing]
    F --> G[Frame 1 Analysis]
    F --> H[Frame 2 Analysis]
    F --> I[Frame 3 Analysis]
    F --> J[Frame 4 Analysis]
    F --> K[Frame 5 Analysis]
    
    G --> L[OpenAI Vision API]
    H --> L
    I --> L
    J --> L
    K --> L
    
    L --> M[Frame Descriptions<br/>with Timestamps]
    
    A --> N[Extract Audio<br/>ffmpeg]
    N --> O[Convert to WAV<br/>PCM 16-bit<br/>44.1kHz Stereo]
    O --> P[ElevenLabs STT API<br/>scribe_v1]
    P --> Q{Retry Logic<br/>Rate Limited?}
    Q -->|Yes| R[Exponential Backoff<br/>2s, 4s, 8s]
    R --> P
    Q -->|No| S[Transcription Result<br/>Text + Word Timestamps]
    
    M --> T[Combine Results]
    S --> T
    T --> U[JSON Response<br/>Frames + Audio]
```

**Frame Extraction Algorithm:**
```python
# Calculate evenly-spaced frame indices
total_frames = cap.get(cv2.CAP_PROP_FRAME_COUNT)
fps = cap.get(cv2.CAP_PROP_FPS)
num_frames = 5

step = max(1, total_frames // num_frames)
frame_indices = [i * step for i in range(min(num_frames, total_frames))]

# Extract frames
for frame_idx in frame_indices:
    cap.set(cv2.CAP_PROP_POS_FRAMES, frame_idx)
    ret, frame = cap.read()
    timestamp = frame_idx / fps
```

**Audio Extraction (ffmpeg):**
```bash
ffmpeg -i video.mp4 \
  -vn \                    # No video
  -acodec pcm_s16le \     # PCM 16-bit little-endian
  -ar 44100 \              # Sample rate
  -ac 2 \                  # Stereo
  -y \                     # Overwrite
  audio.wav
```

**ElevenLabs Retry Logic:**
```python
for attempt in range(max_retries + 1):
    try:
        response = requests.post(url, files=files, data=data)
        if response.status_code == 200:
            return response.json()
        elif response.status_code == 429:  # Rate limited
            delay = base_delay * (2 ** attempt)  # Exponential backoff
            time.sleep(delay)
            continue
    except RequestException as e:
        # Retry with exponential backoff
```

---

## 🗄️ FAISS Vector Database Architecture

```mermaid
graph TB
    subgraph "Index Structure"
        A[FAISS IndexFlatL2<br/>1536 dimensions] --> B[Vector Storage<br/>Binary Format]
        A --> C[Metadata Storage<br/>Pickle Format]
    end
    
    subgraph "Vector Operations"
        D[Add Vector] --> E[Reshape: 1x1536]
        E --> F[faiss_index.add]
        F --> G[Increment ntotal]
        
        H[Search Query] --> I[Reshape: 1x1536]
        I --> J[faiss_index.search<br/>query, k=5]
        J --> K[Return: distances, indices]
    end
    
    subgraph "Metadata Schema"
        C --> L[image_path: str]
        C --> M[description: str]
        C --> N[description_variation: int<br/>1-5]
        C --> O[image_index: int<br/>optional]
    end
    
    subgraph "Persistence"
        B --> P[faiss_index.bin<br/>Binary File]
        C --> Q[faiss_metadata.pkl<br/>Pickle File]
        P --> R[Load on Startup]
        Q --> R
        R --> S[Save on Shutdown]
    end
```

**FAISS Index Details:**
- **Index Type**: `IndexFlatL2` - Exact L2 distance search
- **Vector Dimension**: 1536 (OpenAI text-embedding-3-small)
- **Data Type**: `float32`
- **Search Method**: Brute force (exact, not approximate)
- **Storage Format**: Binary (FAISS native) + Pickle (metadata)

**Index Operations:**
```python
# Initialize
faiss_index = faiss.IndexFlatL2(1536)

# Add vectors (batch or single)
vectors = np.array([[0.1, 0.2, ...], ...])  # shape: (n, 1536)
faiss_index.add(vectors)

# Search
query = np.array([[0.15, 0.25, ...]])  # shape: (1, 1536)
distances, indices = faiss_index.search(query, k=5)
# distances: [[0.5, 0.7, 0.9, 1.1, 1.3]]
# indices: [[42, 15, 88, 3, 127]]
```

---

## 🔄 Complete Request Flow: Image Search

```mermaid
sequenceDiagram
    participant User
    participant Flutter
    participant FastAPI
    participant OpenAI_Vision
    participant OpenAI_Embeddings
    participant FAISS
    participant Storage

    User->>Flutter: Upload Image
    Flutter->>FastAPI: POST /search-images<br/>(multipart/form-data)
    
    FastAPI->>FastAPI: Read image bytes
    FastAPI->>OpenAI_Vision: POST /v1/chat/completions<br/>model: gpt-4o<br/>image: base64
    OpenAI_Vision->>OpenAI_Vision: Analyze image<br/>Generate description
    OpenAI_Vision->>FastAPI: Return description text
    
    FastAPI->>OpenAI_Embeddings: POST /v1/embeddings<br/>model: text-embedding-3-small<br/>input: description
    OpenAI_Embeddings->>OpenAI_Embeddings: Generate 1536-dim vector
    OpenAI_Embeddings->>FastAPI: Return embedding array
    
    FastAPI->>FAISS: Search index<br/>query_vector, k=5
    FAISS->>FAISS: Calculate L2 distances<br/>to all vectors
    FAISS->>FAISS: Sort by distance
    FAISS->>FastAPI: Return top 5<br/>(distances, indices)
    
    FastAPI->>Storage: Load metadata<br/>for indices
    Storage->>FastAPI: Return metadata
    
    FastAPI->>FastAPI: Convert distances<br/>to similarity %
    FastAPI->>FastAPI: Format results<br/>with descriptions
    FastAPI->>Flutter: JSON response<br/>query_description and results array
    Flutter->>User: Display matches
```

---

## 🎬 Video Analysis: Technical Deep Dive

```mermaid
flowchart TD
    A[Video Upload<br/>MP4 bytes] --> B[Write Temp File]
    B --> C[OpenCV VideoCapture]
    C --> D[Get Properties<br/>CAP_PROP_FRAME_COUNT<br/>CAP_PROP_FPS]
    D --> E[Calculate Frame Indices<br/>Evenly Spaced]
    
    E --> F[Extract Frame Loop]
    F --> G[cap.set POS_FRAMES]
    G --> H[cap.read]
    H --> I[cv2.imencode .jpg]
    I --> J[Frame Bytes]
    J --> K[OpenAI Vision API]
    K --> L[Frame Description]
    L --> M[Store: index, timestamp, description]
    
    B --> N[ffmpeg Process]
    N --> O[Extract Audio<br/>-vn -acodec pcm_s16le]
    O --> P[WAV File<br/>44.1kHz Stereo]
    P --> Q[Read Audio Bytes]
    Q --> R[ElevenLabs API]
    R --> S{Status Code}
    S -->|200| T[Transcription JSON]
    S -->|429| U[Rate Limited<br/>Retry with Backoff]
    U --> R
    S -->|Error| V[Return Error<br/>Continue without audio]
    
    M --> W[Combine Results]
    T --> W
    V --> W
    W --> X["JSON Response<br/>frame_analysis array<br/>audio_transcription object<br/>summary object"]
```

**Video Processing Technical Details:**

1. **Frame Extraction:**
   - Uses OpenCV `VideoCapture`
   - Seeks to specific frame indices
   - Encodes frames as JPEG (compressed)
   - Maintains timestamp accuracy

2. **Audio Extraction:**
   - ffmpeg subprocess call
   - Converts to uncompressed WAV
   - Standard format: PCM 16-bit, 44.1kHz, Stereo
   - Temporary file cleanup after processing

3. **Error Handling:**
   - Video errors: Return partial results
   - Audio errors: Continue without transcription
   - API rate limits: Exponential backoff (2s, 4s, 8s)
   - Network errors: Retry up to 3 times

---

## 🧪 AI Model Specifications

### OpenAI GPT-4 Vision (gpt-4o)
```
Model: gpt-4o
Input: 
  - Text prompt (system + user)
  - Image (base64 encoded, JPEG/PNG)
Output: 
  - Text description (max 1500 tokens)
  - Temperature: 0 (deterministic)
  - Response Format: JSON-compatible text
```

### OpenAI Embeddings (text-embedding-3-small)
```
Model: text-embedding-3-small
Input: Text string (description)
Output: 
  - Vector: 1536 dimensions
  - Data Type: float32
  - Normalized: No (raw embeddings)
  - Usage: Semantic similarity search
```

### ElevenLabs Speech-to-Text (scribe_v1)
```
Model: scribe_v1
Input: 
  - Audio file (WAV format)
  - Sample rate: 44100 Hz
  - Channels: Stereo (2)
  - Encoding: PCM 16-bit
Output:
  - Transcription text
  - Word-level timestamps
  - Language code
  - Confidence scores (if available)
```

---

## 📊 Performance Characteristics

### Latency Breakdown (Typical)

| Operation | Time | Notes |
|-----------|------|-------|
| Image Description (GPT-4 Vision) | 2-5s | Depends on image complexity |
| Embedding Generation | 0.5-1s | Fast, cached by OpenAI |
| FAISS Search (1000 vectors) | <10ms | Linear scan, very fast |
| Frame Extraction (5 frames) | 1-2s | OpenCV processing |
| Audio Extraction (ffmpeg) | 2-5s | Depends on video length |
| Audio Transcription | 5-15s | ElevenLabs API + retry logic |

### Scalability Considerations

- **FAISS Index**: 
  - Current: Linear search O(n)
  - Limit: ~1M vectors before performance degrades
  - Future: Switch to `IndexIVFFlat` for approximate search

- **API Rate Limits**:
  - OpenAI: Varies by tier (requests/min)
  - ElevenLabs: Rate limited (429 errors handled)

- **Memory Usage**:
  - FAISS index: ~6KB per vector (1536 * 4 bytes)
  - 1000 images = ~30MB (5 variations each = 5000 vectors)

---

## 🔐 Error Handling & Resilience

```mermaid
flowchart TD
    A[API Request] --> B{Validation}
    B -->|Invalid| C[400 Bad Request]
    B -->|Valid| D[Process Request]
    
    D --> E{OpenAI API}
    E -->|Success| F[Continue]
    E -->|Rate Limit| G[Wait & Retry<br/>Exponential Backoff]
    E -->|Error| H[500 Internal Error]
    G --> E
    
    F --> I{ElevenLabs API}
    I -->|Success| J[Continue]
    I -->|Rate Limit| K[Retry 3x<br/>2s, 4s, 8s]
    I -->|Error| L[Skip Audio<br/>Continue with Frames]
    K --> I
    
    J --> M[Return Results]
    L --> M
    H --> N[Return Error Response]
```

**Retry Strategy:**
- **OpenAI**: No explicit retry (FastAPI handles)
- **ElevenLabs**: 3 retries with exponential backoff
- **ffmpeg**: Single attempt (local process)
- **FAISS**: No retry needed (local operation)

---

## 🗂️ Data Structures

### FAISS Metadata Entry
```python
{
    "image_path": "samples/1.jpg",
    "description": "Detailed food description...",
    "description_variation": 1,  # 1-5
    "image_index": 123  # Optional, parsed from filename
}
```

### Video Analysis Response
```python
{
    "video_filename": "burger.mp4",
    "frame_analysis": [
        {
            "frame_index": 0,
            "timestamp": 0.0,
            "description": "Frame description..."
        }
    ],
    "audio_transcription": {
        "text": "Transcribed text...",
        "words": [
            {"text": "word", "start": 0.5, "end": 0.7}
        ],
        "language": "en"
    },
    "summary": {
        "frames_analyzed": 5,
        "has_audio_transcription": true,
        "processing_time_seconds": 45.2
    }
}
```

---

## 🔧 Configuration & Environment

```python
# Environment Variables
OPENAI_API_KEY=sk-...          # Required
ELEVENLABS_API_KEY=...         # Optional

# FAISS Configuration
EMBEDDING_DIM = 1536
FAISS_INDEX_FILE = "faiss_index.bin"
FAISS_METADATA_FILE = "faiss_metadata.pkl"

# Video Processing
NUM_FRAMES = 5                  # Frames to extract
AUDIO_SAMPLE_RATE = 44100       # Hz
AUDIO_CHANNELS = 2              # Stereo

# API Settings
MAX_TOKENS = 1500               # GPT-4 Vision
TEMPERATURE = 0                 # Deterministic
MAX_RETRIES = 3                 # ElevenLabs
BASE_DELAY = 2.0                # Seconds
```

---

This architecture provides a production-ready AI-powered backend with robust error handling, efficient vector search, and multi-modal video analysis capabilities.

