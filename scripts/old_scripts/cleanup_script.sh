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
declare -A file_sizes

# Initialize counters for progress feedback
file_count=0
dir_count=0
processed_files=0
processed_dirs=0

# Find duplicate files and keep the best quality (largest file size)
echo "Searching for duplicate files in '$BASE_DIR'..."

total_files=$(find "$BASE_DIR" -type f | wc -l)  # Get the total number of files for progress

find "$BASE_DIR" -type f | while read -r file; do
    # Calculate the file's checksum
    checksum=$(md5sum "$file" | awk '{ print $1 }')
    file_size=$(stat -c%s "$file")  # Get the file size in bytes

    # If the checksum is already in the array, it's a duplicate
    if [[ -n "${file_hashes[$checksum]}" ]]; then
        # Compare file sizes and keep the larger one
        if [[ "$file_size" -gt "${file_sizes[$checksum]}" ]]; then
            echo "Deleting smaller duplicate: '${file_hashes[$checksum]}' (Size: ${file_sizes[$checksum]} bytes)"
            rm -vf "${file_hashes[$checksum]}"
            file_hashes["$checksum"]="$file"
            file_sizes["$checksum"]="$file_size"
        else
            echo "Deleting smaller duplicate: '$file' (Size: ${file_size} bytes)"
            rm -vf "$file"
        fi
    else
        # If it's not a duplicate, add it to the array
        file_hashes["$checksum"]="$file"
        file_sizes["$checksum"]="$file_size"
    fi

    # Increment processed file count and show progress
    ((processed_files++))
    echo "Processed $processed_files of $total_files files..."
done

# Find duplicate directories and keep the best quality (largest folder size)
echo "Searching for duplicate directories in '$BASE_DIR'..."

total_dirs=$(find "$BASE_DIR" -type d | wc -l)  # Get the total number of directories for progress

find "$BASE_DIR" -type d | while read -r dir; do
    # Skip non-empty directories
    if [[ -n $(find "$dir" -mindepth 1 -print -quit 2>/dev/null) ]]; then
        continue
    fi

    dir_checksum=$(tar cf - "$dir" | md5sum | awk '{ print $1 }')
    dir_size=$(du -sb "$dir" | cut -f1)  # Get the folder size in bytes

    if [[ -n "${file_hashes[$dir_checksum]}" ]]; then
        if [[ "$dir_size" -gt "${file_sizes[$dir_checksum]}" ]]; then
            echo "Deleting smaller duplicate directory: '${file_hashes[$dir_checksum]}' (Size: ${file_sizes[$dir_checksum]} bytes)"
            rm -rvf "${file_hashes[$dir_checksum]}"
            file_hashes["$dir_checksum"]="$dir"
            file_sizes["$dir_checksum"]="$dir_size"
        else
            echo "Deleting smaller duplicate directory: '$dir' (Size: ${dir_size} bytes)"
            rm -rvf "$dir"
        fi
    else
        file_hashes["$dir_checksum"]="$dir"
        file_sizes["$dir_checksum"]="$dir_size"
    fi

    # Increment processed directory count and show progress
    ((processed_dirs++))
    echo "Processed $processed_dirs of $total_dirs directories..."
done

echo "Cleanup of duplicates complete!"
