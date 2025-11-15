# How to Export Diagrams to Images

## Quick Start

1. Open any `.html` file in a browser
2. The diagram will display automatically
3. Use one of the methods below for export

---

## Updated Diagrams

All diagrams now have:
- **Increased font** (18px)
- **Compact design** (less empty space)
- **Improved connections** (ElevenLabs connected to GPT-4)
- **Bold text** for headings
- **Professional appearance**

---

## Method 1: Screenshot (Simplest)

### Windows
1. Open `complete_system_diagram.html` in browser
2. Press **Win + Shift + S**
3. Select diagram area
4. Paste into PowerPoint/Word/any editor

### macOS
1. Open file in browser
2. Press **Cmd + Shift + 4**
3. Select area
4. File will be saved to desktop

---

## Method 2: Export to PDF (High Quality)

### Chrome/Edge
1. Open diagram in browser
2. Right-click → **Print** (or Ctrl+P)
3. Destination: **Save as PDF**
4. Layout: **Landscape**
5. More settings:
   - Margins: **None**
   - Background graphics: **✓ Enabled**
6. Click **Save**

### Firefox
1. Open diagram
2. Ctrl+P (Print)
3. Print to: **Microsoft Print to PDF**
4. Save

---

## Method 3: Browser Extensions (Recommended for PNG)

### Chrome

**Full Page Screen Capture** (Free)
1. Install: https://chrome.google.com/webstore/detail/full-page-screen-capture/fdpohaocaechififmbbbbbknoalclacl
2. Open diagram
3. Click extension icon
4. Download PNG

**FireShot** (Free)
1. Install: https://chrome.google.com/webstore/detail/fireshot/mcbpblocgmgfnpjjppndjkmgjaogfceg
2. Open diagram
3. Click icon
4. "Capture entire page" → Save as PNG

### Firefox

**Fireshot for Firefox**
1. Install: https://addons.mozilla.org/en-US/firefox/addon/fireshot/
2. Open diagram
3. Use extension for export

---

## Method 4: Mermaid CLI (Professional)

For developers - best method for automation.

### Installation

```bash
npm install -g @mermaid-js/mermaid-cli
```

### Export to PNG (High Resolution)

```bash
# Main export
mmdc -i complete_system_diagram.html -o system_architecture.png -w 2400 -H 1800

# All diagrams
mmdc -i complete_system_diagram.html -o complete_system.png -w 2400 -H 1800
mmdc -i backend_diagram.html -o backend.png -w 2400 -H 1600
mmdc -i backend_flow_diagram.html -o backend_flow.png -w 2400 -H 1400
mmdc -i video_analysis_diagram.html -o video_analysis.png -w 2400 -H 1600
mmdc -i image_indexing_diagram.html -o image_indexing.png -w 2400 -H 1600
```

### Export to SVG (Vector Format)

```bash
mmdc -i complete_system_diagram.html -o system_architecture.svg

# SVG advantages:
# - Scales without quality loss
# - Perfect for printing
# - Can be edited in Illustrator/Inkscape
```

### Export to PDF

```bash
mmdc -i complete_system_diagram.html -o system_architecture.pdf
```

---

## Method 5: Online Tools

### Mermaid Live Editor
1. Open https://mermaid.live/
2. Copy Mermaid code from HTML file (between `<div class="mermaid">` and `</div>`)
3. Paste into editor
4. Click **Download PNG** or **Download SVG**

### Diagrams.net (draw.io)
1. Open https://app.diagrams.net/
2. File → Import from → **Mermaid...**
3. Paste code
4. Export as PNG/SVG/PDF

---

## Recommended Export Settings

### For Presentation (PowerPoint/Google Slides)
- **Format**: PNG
- **Resolution**: 2400x1800px
- **DPI**: 300
- **Quality**: Maximum

### For Documentation (Markdown/README)
- **Format**: PNG or SVG
- **Resolution**: 1920x1440px
- **DPI**: 150-200

### For Printing
- **Format**: PDF or SVG
- **Resolution**: Maximum
- **Paper size**: A4 or A3
- **Orientation**: Landscape

### For Website
- **Format**: PNG (optimized) or WebP
- **Resolution**: 1600x1200px
- **Optimization**: Use TinyPNG or ImageOptim

---

## Image Optimization

After export, you can optimize file sizes:

### Online Tools
- **TinyPNG**: https://tinypng.com/ (PNG compression)
- **Squoosh**: https://squoosh.app/ (Google, supports all formats)
- **Compress PNG**: https://compresspng.com/

### Command Line
```bash
# Install ImageMagick
# Windows: choco install imagemagick
# macOS: brew install imagemagick

# PNG optimization
magick system_architecture.png -quality 90 -resize 2400x1800 optimized.png

# Convert to WebP (smaller size)
magick system_architecture.png -quality 90 system_architecture.webp
```

---

## Tips for Best Quality

1. **Use fullscreen mode** (F11) before export
2. **Disable browser extensions** that may interfere with rendering
3. **Use Chrome or Edge** for best Mermaid support
4. **Scale browser to 100%** (Ctrl+0) before export
5. **For printing use PDF or SVG** formats

---

## Troubleshooting

### Diagram not displaying
- Check internet connection (Mermaid loads from CDN)
- Clear browser cache (Ctrl+Shift+Delete)
- Try different browser

### Low export quality
- Use PDF instead of PNG
- Increase resolution in settings
- Use Mermaid CLI for better quality

### Text too small
- Open HTML file and change `fontSize: '18px'` to `'20px'` or `'22px'`
- Or use zoom in browser before export

---

## Export Checklist

- [ ] Opened diagram in browser
- [ ] Verified all elements display correctly
- [ ] Chose export method
- [ ] Set correct resolution/quality
- [ ] Exported file
- [ ] Checked quality of exported file
- [ ] (Optional) Optimized file size
- [ ] Done!

---

**Recommendation**: For important presentations, use **Method 2 (PDF)** or **Method 4 (Mermaid CLI PNG)** for best quality.
