#!/bin/bash

# Check if the path is provided
if [ -z "$1" ]; then
  echo "Usage: $0 /path/to/movies/library"
  exit 1
fi

# Set the provided path
MOVIES_PATH="$1"

# Ensure the path exists
if [ ! -d "$MOVIES_PATH" ]; then
  echo "Error: The provided path '$MOVIES_PATH' does not exist."
  exit 1
fi

# Find and delete unwanted files, while printing the file names
find "$MOVIES_PATH" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.txt" \) -print -exec rm -v {} \;

# Output completion message
echo "Deletion of image and text files completed in '$MOVIES_PATH'."
