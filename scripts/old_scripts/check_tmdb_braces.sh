#!/bin/bash

# Directory to search
SEARCH_DIR="/mnt/stwelve/data/media/movies"

# Check if the search directory exists
if [ ! -d "$SEARCH_DIR" ]; then
    echo "Error: Directory '$SEARCH_DIR' does not exist."
    exit 1
fi

echo "Checking for folders without '{tmdb-}' in '$SEARCH_DIR'..."

# Find all top-level directories that do NOT contain '{tmdb-}'
found=0
find "$SEARCH_DIR" -maxdepth 1 -type d -not -path "$SEARCH_DIR" -not -name "*{tmdb-*}" | while IFS= read -r dir; do
    # Get human-readable size
    size=$(du -sh "$dir" | cut -f1)
    echo "Found folder without '{tmdb-}': '$dir' ($size)"
    found=1
done

if [ "$found" -eq 0 ]; then
    echo "All folders contain '{tmdb-}'. No outliers found."
else
    echo "Found $found folder(s) without '{tmdb-}'. Review the list above."
fi

exit 0
