#!/bin/bash

# Check if the user provided a path
if [ -z "$1" ]; then
  echo "Usage: $0 <directory_path>"
  exit 1
fi

# Define the directory to search
SEARCH_DIR="$1"

# Define the video file extensions to search for
VIDEO_EXTENSIONS="mp4|mkv|avi|mov|flv|wmv|webm|mpeg|mpg|m4v|3gp"

# Loop through each subfolder in the directory
find "$SEARCH_DIR" -type d | while read -r folder; do
  # Count the video files in this folder
  video_count=$(find "$folder" -maxdepth 1 -type f \( -iname "*.mp4" -o -iname "*.mkv" -o -iname "*.avi" -o -iname "*.mov" -o -iname "*.flv" -o -iname "*.wmv" -o -iname "*.webm" -o -iname "*.mpeg" -o -iname "*.mpg" -o -iname "*.m4v" -o -iname "*.3gp" \) | wc -l)

  # If the folder has more than one video file, display the information
  if [ "$video_count" -gt 1 ]; then
    echo "Folder: $folder"
    echo "Number of video files: $video_count"
    
    # List the video files and their sizes
    find "$folder" -maxdepth 1 -type f \( -iname "*.mp4" -o -iname "*.mkv" -o -iname "*.avi" -o -iname "*.mov" -o -iname "*.flv" -o -iname "*.wmv" -o -iname "*.webm" -o -iname "*.mpeg" -o -iname "*.mpg" -o -iname "*.m4v" -o -iname "*.3gp" \) -print0 | while IFS= read -r -d '' file; do
      file_size=$(du -h "$file" | cut -f1)
      echo "  File: $(basename "$file") | Size: $file_size"
    done

    # Calculate the total size of video files in the folder
    total_folder_size=$(find "$folder" -maxdepth 1 -type f \( -iname "*.mp4" -o -iname "*.mkv" -o -iname "*.avi" -o -iname "*.mov" -o -iname "*.flv" -o -iname "*.wmv" -o -iname "*.webm" -o -iname "*.mpeg" -o -iname "*.mpg" -o -iname "*.m4v" -o -iname "*.3gp" \) -exec du -ch {} + | grep total$ | awk '{print $1}')
    echo "Total size of video files in this folder: $total_folder_size"
    echo ""
  fi
done
