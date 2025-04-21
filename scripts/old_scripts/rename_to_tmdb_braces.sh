#!/bin/bash

# Directory to search
SEARCH_DIR="/mnt/stwelve/data/media/movies"

# Check if the search directory exists
if [ ! -d "$SEARCH_DIR" ]; then
    echo "Error: Directory '$SEARCH_DIR' does not exist."
    exit 1
fi

echo "Checking for folders without '{tmdb-}' in '$SEARCH_DIR'..."

# Counter for folders found and renamed
found=0
renamed=0

# Find all top-level directories with 'tmdb-' but without '{tmdb-}'
find "$SEARCH_DIR" -maxdepth 1 -type d -name "* tmdb-*" ! -name "*{tmdb-*}" | while IFS= read -r old_dir; do
    # Increment found counter
    found=$((found + 1))
    
    # Get the size for reporting
    size=$(du -sh "$old_dir" | cut -f1)
    echo "Found folder without '{tmdb-}': '$old_dir' ($size)"
    
    # Construct the new name by replacing ' tmdb-' with ' {tmdb-}'
    new_dir=$(echo "$old_dir" | sed 's/ tmdb-\([0-9]*\)$/ {tmdb-\1}/')
    
    # Check if the new name already exists to avoid overwriting
    if [ -d "$new_dir" ]; then
        echo "Warning: '$new_dir' already exists. Skipping rename of '$old_dir'."
    else
        echo "Renaming: '$old_dir' -> '$new_dir'"
        mv "$old_dir" "$new_dir"
        renamed=$((renamed + 1))
    fi
done

# Summary
if [ "$found" -eq 0 ]; then
    echo "All folders already contain '{tmdb-}'. No changes needed."
else
    echo "Found $found folder(s) without '{tmdb-}'. Renamed $renamed folder(s) to include '{tmdb-}'."
    if [ "$renamed" -lt "$found" ]; then
        echo "Note: Some folders were not renamed due to existing duplicates. Review warnings above."
    fi
fi

exit 0
