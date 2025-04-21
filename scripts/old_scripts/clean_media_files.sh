#!/bin/bash

# Set the main path
MAIN_PATH="/mnt/user/data/media/movies"

# Define media file extensions to look for
MEDIA_EXTENSIONS="mp4|mkv|avi|mov|wmv|flv"

# Function to find and process duplicate files
process_duplicates() {
    local folder="$1"
    local largest_file=""
    local largest_size=0

    echo "Checking folder: \"$folder\""

    # Find all media files in the current folder
    find "$folder" -maxdepth 1 -type f -regextype posix-extended -regex ".*\.($MEDIA_EXTENSIONS)" | while IFS= read -r file; do
        if [ -f "$file" ]; then
            # Get the file size
            file_size=$(stat -c%s "$file")

            echo "Found file: \"$file\" with size $file_size bytes"

            # Check if this file is larger than the current largest
            if (( file_size > largest_size )); then
                largest_file="$file"
                largest_size=$file_size
            fi
        fi
    done

    # If a largest file was found, delete all smaller files
    if [ -n "$largest_file" ]; then
        echo "Largest file in \"$folder\" is \"$largest_file\" with size $largest_size bytes"
        find "$folder" -maxdepth 1 -type f -regextype posix-extended -regex ".*\.($MEDIA_EXTENSIONS)" | while IFS= read -r file; do
            if [ "$file" != "$largest_file" ]; then
                echo "Deleting smaller file: \"$file\""
                rm -f "$file"
            fi
        done
    fi
}

# Recursively process each folder in the main path
find "$MAIN_PATH" -type d | while IFS= read -r folder; do
    process_duplicates "$folder"
done

echo "Process completed."
