#!/bin/bash

# Check if a directory path was provided as an argument
if [ -z "$1" ]; then
    echo "Usage: $0 /path/to/directory"
    exit 1
fi

# Directory where you want to start searching
BASE_DIR="$1"

# Check if the provided directory exists
if [ ! -d "$BASE_DIR" ]; then
    echo "Error: Directory '$BASE_DIR' does not exist."
    exit 1
fi

# Associative array to store checksums and corresponding files
declare -A file_hashes

# Find duplicate files and delete them
echo "Searching for duplicate files in '$BASE_DIR'..."

find "$BASE_DIR" -type f | while read -r file; do
    # Calculate the file's checksum
    checksum=$(md5sum "$file" | awk '{ print $1 }')

    # If the checksum is already in the array, it's a duplicate
    if [[ -n "${file_hashes[$checksum]}" ]]; then
        echo "Duplicate found: '$file' (duplicate of '${file_hashes[$checksum]}')"
        rm -vf "$file"
    else
        # If it's not a duplicate, add it to the array
        file_hashes["$checksum"]="$file"
    fi
done

# Find duplicate directories and delete them
echo "Searching for duplicate directories in '$BASE_DIR'..."

find "$BASE_DIR" -type d | while read -r dir; do
    if [[ -n $(find "$dir" -mindepth 1 -print -quit 2>/dev/null) ]]; then
        continue
    fi

    dir_checksum=$(tar cf - "$dir" | md5sum | awk '{ print $1 }')

    if [[ -n "${file_hashes[$dir_checksum]}" ]]; then
        echo "Duplicate directory found: '$dir' (duplicate of '${file_hashes[$dir_checksum]}')"
        rm -rvf "$dir"
    else
        file_hashes["$dir_checksum"]="$dir"
    fi
done

echo "Cleanup of duplicates complete!"
