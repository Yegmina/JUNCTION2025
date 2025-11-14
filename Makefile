.PHONY: venv setup run upload-samples test clean help

VENV = venv
PYTHON = $(VENV)/bin/python
PIP = $(VENV)/bin/pip
SERVER_URL = http://localhost:8000
SAMPLES_DIR = samples

help:
	@echo "Available targets:"
	@echo "  make venv          - Create virtual environment"
	@echo "  make setup          - Install dependencies"
	@echo "  make run            - Run the FastAPI server"
	@echo "  make upload-samples - Upload all images from samples/ directory"
	@echo "  make test           - Test search with test.jpg"
	@echo "  make clean          - Remove virtual environment and FAISS files"

venv:
	@echo "Creating virtual environment..."
	python3 -m venv $(VENV)

setup: venv
	@echo "Installing dependencies..."
	$(PIP) install --upgrade "pip" "setuptools" "wheel" "packaging<25"
	@echo "Reinstalling numpy to fix potential corruption..."
	$(PIP) uninstall -y numpy || true
	$(PIP) install --force-reinstall --no-cache-dir "numpy>=1.26.0,<2.0"
	$(PIP) install -r requirements.txt
	@echo "Setup complete! Make sure to create .env file with OPENAI_API_KEY"

run: setup
	@echo "Starting FastAPI server..."
	$(PYTHON) -m uvicorn main:app --reload --host 0.0.0.0 --port 8000

upload-samples: setup
	@echo "Uploading images from $(SAMPLES_DIR)/..."
	@if [ ! -d "$(SAMPLES_DIR)" ]; then \
		echo "Error: $(SAMPLES_DIR) directory not found"; \
		exit 1; \
	fi
	@for img in $(SAMPLES_DIR)/*.jpg $(SAMPLES_DIR)/*.jpeg $(SAMPLES_DIR)/*.png; do \
		if [ -f "$$img" ] 2>/dev/null; then \
			echo "Uploading $$img..."; \
			curl -X POST "$(SERVER_URL)/add-image" \
				-F "file=@$$img" \
				-F "image_path=$$img" \
				-H "Content-Type: multipart/form-data" || echo "Failed to upload $$img"; \
		fi; \
	done 2>/dev/null || true
	@echo "Upload complete! Checking index stats..."
	@curl -s "$(SERVER_URL)/index-stats" | python3 -m json.tool || echo "Server may not be running"

test: setup
	@echo "Testing search with test.jpg..."
	@if [ ! -f "test.jpg" ]; then \
		echo "Error: test.jpg not found"; \
		exit 1; \
	fi
	@echo "Searching for similar images..."
	@curl -X POST "$(SERVER_URL)/search-images" \
		-F "file=@test.jpg" \
		-H "Content-Type: multipart/form-data" | python3 -m json.tool || echo "Server may not be running or index is empty"

clean:
	@echo "Cleaning up..."
	rm -rf $(VENV)
	rm -f faiss_index.bin faiss_metadata.pkl
	@echo "Clean complete!"
