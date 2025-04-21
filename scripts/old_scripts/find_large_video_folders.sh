#!/bin/bash

# Check if path is provided
if [ -z "$1" ]; then
    echo "Usage: $0 <path>"
    exit 1
fi

SEARCH_PATH="$1"

# Function to check if a file is a video file based on extension
is_video_file() {
    local file="$1"
    case "${file,,}" in
        *.mp4|*.mkv|*.avi|*.mov|*.wmv|*.flv|*.m4v|*.webm|*.ts|*.m2ts)
            return 0
            ;;
        *)
            return 1
            ;;
    esac
}

# Traverse directories and count video files
find "$SEARCH_PATH" -type d | while read -r dir; do
    video_count=0
    total_size=0

    # Loop through files in the directory
    for file in "$dir"/*; do
        if [ -f "$file" ] && is_video_file "$file"; then
            ((video_count++))
            total_size=$((total_size + $(du -b "$file" | cut -f1)))
        fi
    done

    # If the directory contains more than one video file, display the result
    if [ "$video_count" -gt 1 ]; then
        echo "Folder: $dir"
        echo "Video files: $video_count"
        echo "Total size: $(numfmt --to=iec --suffix=B $total_size)"
        echo "-------------------------------------"
    fi
done
