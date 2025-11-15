#!/usr/bin/env python3
"""
Fake YOLO Detection Video - Burger Video Specific
Uses real YOLO detection but hardcodes class mapping to output: burger, cucumbers, fries, sauce
"""

import cv2
import numpy as np
from pathlib import Path
from ultralytics import YOLO
from typing import List, Tuple, Dict


class FoodClassMapper:
    """Hardcoded mapping specific to burger video to translate YOLO classes to food classes"""
    
    # Color mapping for each food class (BGR format for OpenCV)
    CLASS_COLORS = {
        'burger': (0, 255, 0),      # Green
        'fries': (255, 165, 0),     # Orange
        'sauce': (0, 0, 255),       # Red
        'cucumbers': (255, 255, 0), # Cyan/Yellow
    }
    
    def __init__(self, frame_width: int, frame_height: int):
        self.frame_width = frame_width
        self.frame_height = frame_height
        
        # Define regions specific to burger video (576x1024 based on ffmpeg output)
        # These are hardcoded positions for this specific video
        self.center_x = frame_width // 2
        self.center_y = frame_height // 2
        
        # Region thresholds (as fractions of frame size)
        self.center_threshold = 0.4  # Center 40% region
        self.right_threshold = 0.65  # Right 35% region
        
    def map_detection_to_food_class(
        self, 
        class_name: str, 
        confidence: float,
        bbox_xyxy: Tuple[float, float, float, float]
    ) -> str:
        """
        Map YOLO detection to food class based on class name and position.
        Hardcoded logic specific to burger video.
        
        Args:
            class_name: YOLO detected class name
            class_name: Detection confidence
            bbox_xyxy: Bounding box coordinates (x1, y1, x2, y2)
            
        Returns:
            Mapped food class name or None if should be ignored
        """
        x1, y1, x2, y2 = bbox_xyxy
        box_center_x = (x1 + x2) / 2
        box_center_y = (y1 + y2) / 2
        box_width = x2 - x1
        box_height = y2 - y1
        box_area = box_width * box_height
        
        # Normalize positions
        center_x_ratio = box_center_x / self.frame_width
        center_y_ratio = box_center_y / self.frame_height
        
        class_lower = class_name.lower()
        
        # Always exclude person/hand detections - these are the hands holding the burger
        if class_lower in ['person', 'hand']:
            return None
        
        # Mapping logic specific to burger video
        # 1. Burger: sandwich-like objects in center region
        if (class_lower in ['sandwich', 'hot dog', 'pizza'] or 
            (class_lower in ['food'] and 
             0.3 < center_x_ratio < 0.7 and 
             0.25 < center_y_ratio < 0.75 and
             box_area > 0.15 * self.frame_width * self.frame_height)):
            return 'burger'
        
        # 2. Sauce: small containers, cups, bottles on left side (lower region)
        if (class_lower in ['cup', 'bottle', 'bowl', 'container'] and
            center_x_ratio < 0.25 and center_y_ratio > 0.6):
            return 'sauce'
        elif (box_area < 0.04 * self.frame_width * self.frame_height and
              center_x_ratio < 0.25 and center_y_ratio > 0.6):
            return 'sauce'
        
        # 3. Fries: look for food items in right side, upper region (above burger)
        # Fries are horizontal and positioned above the burger center
        # Must be food-like, horizontal, and in the upper-right region
        if (class_lower in ['fork', 'knife', 'spoon', 'food', 'bowl'] or
            (center_x_ratio > 0.65 and
             center_y_ratio < 0.5 and  # Upper region (above burger center)
             0.02 < box_area / (self.frame_width * self.frame_height) < 0.15 and
             box_width > box_height * 1.2)):  # Clearly horizontal (width > 1.2 * height)
            return 'fries'
        
        # 4. Cucumbers/Pickles: small bowls in top right corner or vegetable items
        if (class_lower in ['carrot', 'vegetable', 'onion', 'lettuce'] or
            (class_lower in ['bowl', 'container', 'cup'] and 
             center_x_ratio > 0.75 and center_y_ratio < 0.25) or
            (center_x_ratio > 0.75 and center_y_ratio < 0.3 and 
             box_area < 0.06 * self.frame_width * self.frame_height)):
            return 'cucumbers'
        
        # Fallback: map based on position alone if confidence is high
        # Exclude person from all fallback mappings
        if confidence > 0.5 and class_lower not in ['person', 'hand']:
            # Center region with medium size → burger
            if (0.3 < center_x_ratio < 0.7 and 
                0.25 < center_y_ratio < 0.75 and
                0.1 < box_area / (self.frame_width * self.frame_height) < 0.3):
                return 'burger'
            # Right side, upper region (above burger), horizontal → fries
            # Must be wide/horizontal, upper position, and not too large (avoid person)
            elif (center_x_ratio > 0.65 and 
                  center_y_ratio < 0.5 and  # Upper region (above burger)
                  0.02 < box_area / (self.frame_width * self.frame_height) < 0.15 and
                  box_width > box_height * 1.2):  # Clearly horizontal
                return 'fries'
            # Top right corner, small → cucumbers (pickles)
            elif (center_x_ratio > 0.75 and center_y_ratio < 0.3 and
                  box_area < 0.06 * self.frame_width * self.frame_height):
                return 'cucumbers'
            # Small objects on left edges, lower → sauce
            elif (center_x_ratio < 0.25 and center_y_ratio > 0.6 and
                  box_area < 0.04 * self.frame_width * self.frame_height):
                return 'sauce'
        
        return None  # Ignore this detection


def process_video_with_yolo(
    input_video_path: str,
    output_video_path: str,
    model_name: str = "yolov8n.pt"
):
    """
    Process video with YOLO detection and apply hardcoded food class mapping.
    
    Args:
        input_video_path: Path to input video
        output_video_path: Path to output annotated video
        model_name: YOLO model name
    """
    print(f"Loading YOLO model: {model_name}...")
    model = YOLO(model_name)
    print("✅ Model loaded successfully")
    
    # Open input video
    cap = cv2.VideoCapture(input_video_path)
    if not cap.isOpened():
        print(f"❌ Error: Could not open video: {input_video_path}")
        return False
    
    # Get video properties
    fps = int(cap.get(cv2.CAP_PROP_FPS))
    width = int(cap.get(cv2.CAP_PROP_FRAME_WIDTH))
    height = int(cap.get(cv2.CAP_PROP_FRAME_HEIGHT))
    total_frames = int(cap.get(cv2.CAP_PROP_FRAME_COUNT))
    
    print(f"Video properties: {width}x{height} @ {fps} fps, {total_frames} frames")
    
    # Initialize mapper
    mapper = FoodClassMapper(width, height)
    
    # Set up video writer
    fourcc = cv2.VideoWriter_fourcc(*'mp4v')
    out = cv2.VideoWriter(output_video_path, fourcc, fps, (width, height))
    
    frame_count = 0
    print("\nProcessing video frames...")
    
    # Track detected classes to ensure we show all desired classes
    class_tracker = {'burger': False, 'fries': False, 'sauce': False, 'cucumbers': False}
    
    # Import random for randomization
    import random
    random.seed(42)  # For reproducible results
    
    while True:
        ret, frame = cap.read()
        if not ret:
            break
        
        frame_count += 1
        
        # Calculate current time in seconds
        current_time = frame_count / fps
        
        # Run YOLO detection on frame
        results = model(frame, verbose=False)
        
        # Reset tracker for this frame
        frame_class_tracker = {'burger': False, 'fries': False, 'sauce': False, 'cucumbers': False}
        
        # Process detections - collect best detection per food class
        annotated_frame = frame.copy()
        best_detections = {}  # food_class -> (x1, y1, x2, y2, confidence)
        
        if results and len(results) > 0:
            result = results[0]
            
            if result.boxes is not None:
                boxes = result.boxes
                
                for i in range(len(boxes)):
                    # Get box coordinates
                    box = boxes.xyxy[i].cpu().numpy()
                    x1, y1, x2, y2 = box
                    
                    # Get class ID and name
                    class_id = int(boxes.cls[i].cpu().numpy())
                    class_name = model.names[class_id]
                    
                    # Get confidence
                    confidence = float(boxes.conf[i].cpu().numpy())
                    
                    # Map to food class
                    food_class = mapper.map_detection_to_food_class(
                        class_name, confidence, (x1, y1, x2, y2)
                    )
                    
                    if food_class:
                        # Update tracker
                        class_tracker[food_class] = True
                        
                        # Keep only the best (highest confidence) detection per class
                        if food_class not in best_detections or confidence > best_detections[food_class][4]:
                            best_detections[food_class] = (x1, y1, x2, y2, confidence)
        
        # Draw the best detection for each food class
        for food_class, (x1, y1, x2, y2, confidence) in best_detections.items():
            frame_class_tracker[food_class] = True
            
            # Get color for this class
            color = mapper.CLASS_COLORS[food_class]
            
            # Draw bounding box
            x1, y1, x2, y2 = int(x1), int(y1), int(x2), int(y2)
            cv2.rectangle(annotated_frame, (x1, y1), (x2, y2), color, 2)
            
            # Prepare label
            label = f"{food_class} {confidence:.2f}"
            
            # Get text size for background
            (text_width, text_height), baseline = cv2.getTextSize(
                label, cv2.FONT_HERSHEY_SIMPLEX, 0.6, 2
            )
            
            # Draw label background
            cv2.rectangle(
                annotated_frame,
                (x1, y1 - text_height - baseline - 5),
                (x1 + text_width, y1),
                color,
                -1
            )
            
            # Draw label text
            cv2.putText(
                annotated_frame,
                label,
                (x1, y1 - baseline - 3),
                cv2.FONT_HERSHEY_SIMPLEX,
                0.6,
                (255, 255, 255),
                2
            )
        
        # If some classes weren't detected, add hardcoded boxes (specific to burger video)
        # This ensures we always show burger, fries, sauce, and cucumbers
        # Add hardcoded boxes for any class that wasn't detected in this frame
        hardcoded_boxes = {}
        
        if not frame_class_tracker.get('burger'):
            # Burger in center
            hardcoded_boxes['burger'] = (
                int(width * 0.2), int(height * 0.25),
                int(width * 0.8), int(height * 0.75)
            )
        
        # Add time-based fries boxes with randomization
        # Time range 1: 0.00 to 0.75 seconds
        # Time range 2: 2.425 to 5.110 seconds
        # Always show fries in these time ranges (override YOLO detection if needed)
        if 0.00 <= current_time <= 0.75:
            # Fries: upper than burger, from center of upper part to right to end of burger
            # Much smaller randomization for less visible variation
            x1_offset = random.uniform(-3, 3)
            y1_offset = random.uniform(-2, 2)
            x2_offset = random.uniform(-2, 2)
            y2_offset = random.uniform(-2, 2)
            
            hardcoded_boxes['fries'] = (
                int(width * 0.38 + x1_offset), int(height * 0.15 + y1_offset),  # Extended more left
                int(width * 0.80 + x2_offset), int(height * 0.35 + y2_offset)  # Right border stays same
            )
        elif 2.425 <= current_time <= 5.110:
            # Fries: even more right than previous
            # Much smaller randomization for less visible variation
            x1_offset = random.uniform(-3, 3)
            y1_offset = random.uniform(-2, 2)
            x2_offset = random.uniform(-2, 2)
            y2_offset = random.uniform(-2, 2)
            
            hardcoded_boxes['fries'] = (
                int(width * 0.50 + x1_offset), int(height * 0.15 + y1_offset),  # Extended more left
                int(width * 0.90 + x2_offset), int(height * 0.35 + y2_offset)  # Right border stays same
            )
        # No fries in other frames (0.75 < time < 2.425 or time > 5.110)
        
        # Don't add hardcoded sauce box - real YOLO detections (cup/bowl) work well
        # if not frame_class_tracker.get('sauce'):
        #     # Sauce containers on left side, lower region
        #     hardcoded_boxes['sauce'] = (
        #         int(width * 0.05), int(height * 0.65),
        #         int(width * 0.25), int(height * 0.85)
        #     )
        
        # Don't add hardcoded cucumbers box - only show real YOLO detections
        # if not frame_class_tracker.get('cucumbers'):
        #     # Cucumbers/Pickles in top right corner (bowl of pickles)
        #     hardcoded_boxes['cucumbers'] = (
        #         int(width * 0.80), int(height * 0.05),
        #         int(width * 0.95), int(height * 0.25)
        #     )
        
        # Draw hardcoded boxes with randomized confidence
        for food_class, (x1, y1, x2, y2) in hardcoded_boxes.items():
            color = mapper.CLASS_COLORS[food_class]
            
            # Randomize confidence for fries (0.8-0.9), other classes use 0.75
            if food_class == 'fries':
                confidence = random.uniform(0.8, 0.9)
            else:
                confidence = 0.75
            
            # Draw box with dashed style (thinner)
            cv2.rectangle(annotated_frame, (x1, y1), (x2, y2), color, 2)
            
            label = f"{food_class} {confidence:.2f}"
            
            (text_width, text_height), baseline = cv2.getTextSize(
                label, cv2.FONT_HERSHEY_SIMPLEX, 0.6, 2
            )
            
            cv2.rectangle(
                annotated_frame,
                (x1, y1 - text_height - baseline - 5),
                (x1 + text_width, y1),
                color,
                -1
            )
            
            cv2.putText(
                annotated_frame,
                label,
                (x1, y1 - baseline - 3),
                cv2.FONT_HERSHEY_SIMPLEX,
                0.6,
                (255, 255, 255),
                2
            )
        
        # Write frame to output video
        out.write(annotated_frame)
        
        if frame_count % 30 == 0:
            print(f"  Processed {frame_count}/{total_frames} frames")
    
    # Cleanup
    cap.release()
    out.release()
    
    print(f"\n✅ Successfully processed {frame_count} frames")
    print(f"   Output saved to: {output_video_path}")
    print(f"   Detected classes: {', '.join([k for k, v in class_tracker.items() if v])}")
    
    return True


def get_next_output_filename(base_path: str) -> str:
    """
    Get the next available output filename by appending numbers.
    Example: burger_detected.mp4 -> burger_detected_1.mp4 -> burger_detected_2.mp4
    """
    from pathlib import Path
    
    path = Path(base_path)
    directory = path.parent
    stem = path.stem
    suffix = path.suffix
    
    # If file doesn't exist, return original
    if not path.exists():
        return base_path
    
    # Find next available number
    counter = 1
    while True:
        new_path = directory / f"{stem}_{counter}{suffix}"
        if not new_path.exists():
            return str(new_path)
        counter += 1


def main():
    """Main function"""
    import argparse
    
    parser = argparse.ArgumentParser(
        description="Fake YOLO detection on burger video with hardcoded food class mapping",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  python fake_yolo_detection.py
  python fake_yolo_detection.py --model yolov8s.pt
        """
    )
    parser.add_argument(
        "--input",
        "-i",
        default="yolo_faking/burger.mp4",
        help="Input video path (default: yolo_faking/burger.mp4)",
    )
    parser.add_argument(
        "--output",
        "-o",
        default="yolo_faking/burger_detected.mp4",
        help="Output video path (default: yolo_faking/burger_detected.mp4). Auto-increments if file exists.",
    )
    parser.add_argument(
        "--model",
        "-m",
        default="yolov8n.pt",
        help="YOLO model to use (default: yolov8n.pt)",
    )
    
    args = parser.parse_args()
    
    # Auto-increment output filename if it exists
    output_path = get_next_output_filename(args.output)
    if output_path != args.output:
        print(f"Output file exists, using: {output_path}")
    
    success = process_video_with_yolo(args.input, output_path, args.model)
    
    if not success:
        import sys
        sys.exit(1)


if __name__ == "__main__":
    main()

