# Visual Backend Architecture Diagrams

## Beautiful Diagrams for Presentation

5 visually beautiful HTML diagrams that can be opened in a browser and exported as images.

### Updates v2.0
- **Increased font** (18px) - better readability
- **Compact design** - minimum empty space
- **Improved connections** - ElevenLabs connected to GPT-4
- **Bold headings** - improved hierarchy
- **Optimized layout** - perfect for presentations

### Diagram Files

1. **`complete_system_diagram.html`** **MAIN DIAGRAM**
   - Complete architecture of the entire system
   - All components in one place
   - Perfect for presentation
   - Beautiful gradient design

2. **`backend_diagram.html`** - Detailed backend architecture
   - Complete backend structure
   - All API endpoints
   - AI models and their integration
   - Vector database

3. **`backend_flow_diagram.html`** - Data flow through AI
   - Complete processing pipeline
   - Data transformations
   - From input to output
   - Horizontal flow

4. **`video_analysis_diagram.html`** - Video analysis
   - Multimodal processing
   - Visual and audio paths
   - Results combination
   - Retry logic

5. **`image_indexing_diagram.html`** - Image indexing
   - 5-variation strategy
   - Embedding creation process
   - Storage in FAISS
   - Detailed process

## How to Use

> **For export instructions**: See [DIAGRAMS_QUICKSTART.md](DIAGRAMS_QUICKSTART.md)

### Option 1: Open in Browser (Quick Start)

1. Simply open any `.html` file in a browser
2. The diagram will display automatically
3. Use browser tools for export:
   - **Chrome/Edge**: Right-click → "Save as" or Print → Save as PDF
   - **Firefox**: Right-click → "Save image"

### Option 2: Export as PNG/SVG

#### Using Mermaid CLI (Recommended)

```bash
# Install Mermaid CLI
npm install -g @mermaid-js/mermaid-cli

# Export as PNG
mmdc -i backend_diagram.html -o backend_diagram.png -w 2400 -H 1800

# Export as SVG
mmdc -i backend_diagram.html -o backend_diagram.svg
```

#### Using Online Tools

1. Open HTML file in browser
2. Use browser extension for screenshots:
   - **Full Page Screen Capture** (Chrome)
   - **FireShot** (Firefox/Chrome)
3. Or use online services:
   - https://mermaid.live/ (copy code from HTML)
   - https://www.diagrams.net/ (Mermaid import)

### Option 3: Use in Presentation

1. Open HTML in browser
2. Take a screenshot (Win+Shift+S on Windows)
3. Paste into PowerPoint/Google Slides
4. Or use built-in browser export

## Diagram Features

- **Beautiful gradient backgrounds**
- **Color-coded components**
- **Adaptive design**
- **Professional appearance**

## Color Legend

- **Blue** - Client and API layer
- **Green** - AI models (GPT-4, Embeddings, STT)
- **Purple** - Data processing
- **Orange** - Processing tools
- **Pink** - Data storage (FAISS)

## Configuration

You can modify styles in HTML files:
- Background colors in `<style>` section
- Sizes in CSS
- Text and descriptions in diagrams

## Usage Examples

### For Presentation
- Open in browser in full screen
- Use browser presentation mode (F11)
- Take screenshots of needed parts

### For Documentation
- Export as PNG with high resolution
- Insert into Markdown documents
- Use in README files

### For Printing
- Export as PDF
- Use Print → Save as PDF in browser
- Configure page size before printing

## Tips

1. **For best quality**: Use Mermaid CLI for export
2. **For quick viewing**: Simply open HTML in browser
3. **For editing**: Modify Mermaid code in HTML files
4. **For customization**: Configure CSS styles for your brand

---

**All diagrams are ready to use!**

Simply open HTML files in browser and enjoy beautiful visualizations!
