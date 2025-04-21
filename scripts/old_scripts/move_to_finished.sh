#!/bin/bash

# Manually set the source directory
source_directory="/mnt/user/download/torrents/"

# Manually set the destination directory
destination_directory="/mnt/user/download/torrents/finished/"

# Folders and files to exclude from moving
exclude=("baixados" "baixando" "cursos" "finished" "incomplete" "movies" "organize_files.sh" "programas" "tv" "move_to_finished.sh")

# Check if the source directory exists
if [ ! -d "$source_directory" ]; then
    echo "Source directory not found!"
    exit 1
fi

# Check if the destination directory exists, create if not
if [ ! -d "$destination_directory" ]; then
    echo "Destination directory not found. Creating it..."
    mkdir -p "$destination_directory"
fi

# Loop through all items in the source directory
for item in "$source_directory"/*; do
    # Extract the base name of the item
    base_item=$(basename "$item")
    
    # Check if the item is in the exclusion list
    if [[ ! " ${exclude[@]} " =~ " ${base_item} " ]]; then
        # Move the item to the destination directory
        echo "Moving $base_item to $destination_directory/"
        mv "$item" "$destination_directory/"
    else
        echo "Skipping $base_item"
    fi
done

echo "Folders and files have been moved to the destination, excluding the specified ones."
