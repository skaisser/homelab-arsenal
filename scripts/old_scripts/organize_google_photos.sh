#!/bin/bash

# Base directory
BASE_DIR="/mnt/user/bkp-kakau/googlefotosanaclaudiapuc"

# Directories for videos and photos
PHOTO_DIR="$BASE_DIR/photos"
VIDEO_DIR="$BASE_DIR/videos"

# Create directories if they don't exist
mkdir -p "$PHOTO_DIR"
mkdir -p "$VIDEO_DIR"

# File extensions for photos and videos
PHOTO_EXTENSIONS="jpg jpeg png gif heic bmp tiff"
VIDEO_EXTENSIONS="mp4 mov avi mkv m4v flv wmv"

# Function to move files based on their extension
move_files() {
  local extension_list="$1"
  local target_dir="$2"
  
  for ext in $extension_list; do
    find "$BASE_DIR" -type f -iname "*.$ext" -exec mv {} "$target_dir" \;
  done
}

# Move photo files
echo "Moving photo files..."
move_files "$PHOTO_EXTENSIONS" "$PHOTO_DIR"

# Move video files
echo "Moving video files..."
move_files "$VIDEO_EXTENSIONS" "$VIDEO_DIR"

echo "Operation complete. All photos are in '$PHOTO_DIR' and all videos are in '$VIDEO_DIR'."
