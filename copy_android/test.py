#!/usr/bin/env python3
"""
Test script to search for similar images using the FAISS API.
Usage: python3 test.py <image_path> [--top-k K]
"""

import requests
import os
import sys
import argparse

SERVER_URL = "http://localhost:8000"
DEFAULT_TOP_K = 5


def search_image(image_path: str) -> dict:
    """Search for similar images using the uploaded image."""
    if not os.path.exists(image_path):
        print(f"❌ Error: Image file not found: {image_path}")
        return None
    
    # Determine content type based on file extension
    ext = os.path.splitext(image_path)[1].lower()
    content_type = "image/jpeg"
    if ext == ".png":
        content_type = "image/png"
    elif ext in [".jpg", ".jpeg"]:
        content_type = "image/jpeg"
    
    try:
        with open(image_path, "rb") as f:
            files = {"file": (os.path.basename(image_path), f, content_type)}
            
            response = requests.post(
                f"{SERVER_URL}/search-images",
                files=files,
                timeout=30
            )
        
        if response.status_code == 200:
            return response.json()
        else:
            print(f"❌ Search error: {response.status_code}")
            try:
                error_detail = response.json()
                print(f"   {error_detail.get('detail', response.text)}")
            except:
                print(f"   {response.text}")
            return None
    except Exception as e:
        print(f"❌ Error during search: {e}")
        return None


def display_search_results(query_path: str, results: dict, top_k: int):
    """Display search results with similarity percentages and descriptions."""
    if not results:
        print("No results to display")
        return
    
    matches = results.get("results", [])
    
    if not matches:
        print("No matches found in the index.")
        return
    
    # Limit to top_k
    matches = matches[:top_k]
    
    print(f"\nTop {len(matches)} matches:\n")
    
    for match in matches:
        rank = match.get("rank", 0)
        image_path = match.get("image_path", "unknown")
        similarity = match.get("similarity_percentage", 0.0)
        description = match.get("description", "No description")
        
        print(f"  {rank}. {similarity:.2f}% - {image_path}")
        print(f"      {description}")
        print()


def check_server():
    """Check if the server is running."""
    try:
        response = requests.get(f"{SERVER_URL}/index-stats", timeout=5)
        if response.status_code == 200:
            stats = response.json()
            index_size = stats.get("index_size", 0)
            if index_size == 0:
                print("⚠️  Warning: The index is empty. Upload some images first.")
            return True
        return False
    except requests.exceptions.RequestException:
        return False


def main():
    """Main function."""
    parser = argparse.ArgumentParser(
        description="Search for similar images using FAISS API",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  python3 test.py picture.jpg
  python3 test.py samples/1.jpg --top-k 10
        """
    )
    parser.add_argument(
        "image_path",
        help="Path to the image file to search for"
    )
    parser.add_argument(
        "--top-k", "-k",
        type=int,
        default=DEFAULT_TOP_K,
        help=f"Number of top results to display (default: {DEFAULT_TOP_K})"
    )
    
    args = parser.parse_args()
    
    # Check if server is running
    if not check_server():
        print(f"❌ Cannot connect to server at {SERVER_URL}")
        print(f"   Make sure the server is running with: make run")
        sys.exit(1)
    
    # Search for the image
    results = search_image(args.image_path)
    
    if results:
        display_search_results(args.image_path, results, args.top_k)
    else:
        sys.exit(1)


if __name__ == "__main__":
    main()
