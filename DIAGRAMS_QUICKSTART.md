# Quick Start: Backend Diagrams

## Files

5 ready HTML diagrams for presentation:

1. **`complete_system_diagram.html`** - Main (start here!)
2. **`backend_diagram.html`** - Detailed architecture
3. **`backend_flow_diagram.html`** - Data flow
4. **`video_analysis_diagram.html`** - Video analysis
5. **`image_indexing_diagram.html`** - Indexing

## Quick Export

### Windows - Скриншот
```
1. Откройте complete_system_diagram.html
2. Win + Shift + S
3. Выберите область
4. Ctrl + V в PowerPoint
```

### Chrome/Edge - PDF (Лучшее Качество)
```
1. Откройте диаграмму
2. Ctrl + P
3. Save as PDF
4. Margins: None
5. Background graphics: ✓
6. Save
```

### Для Разработчиков - PNG
```bash
npm install -g @mermaid-js/mermaid-cli
mmdc -i complete_system_diagram.html -o diagram.png -w 2400 -H 1800
```

## What's New (v2.0)

- Font increased to 18px
- Compact design (less empty space)
- ElevenLabs connected to GPT-4
- Bold headings
- Ready for presentations

## More Details

- **Полный гайд**: [EXPORT_DIAGRAMS_GUIDE.md](EXPORT_DIAGRAMS_GUIDE.md)
- **Описание**: [README_DIAGRAMS.md](README_DIAGRAMS.md)

---

**Совет**: Для важных презентаций экспортируйте в PDF (Ctrl+P → Save as PDF)

