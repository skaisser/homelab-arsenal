#!/bin/bash

# Check if a directory was provided as an argument
if [ -z "$1" ]; then
    echo "Usage: $0 <directory>"
    exit 1
fi

# Set the directory to the provided argument
directory=$1

# Find and delete empty files
echo "Deleting empty files..."
find "$directory" -type f -empty -print -delete

# Find and delete empty directories
echo "Deleting empty directories..."
find "$directory" -type d -empty -print -delete

echo "Cleanup completed."
