#!/bin/bash

# Directory to search (default is current directory, can be overridden with an argument)
SEARCH_DIR="${1:-.}"

# Check if the search directory exists
if [ ! -d "$SEARCH_DIR" ]; then
    echo "Error: Directory '$SEARCH_DIR' does not exist."
    exit 1
fi

# Find files/directories matching the pattern with 'tmdb-' but not '{tmdb-}'
# Using find to handle filenames with spaces and special characters safely
find "$SEARCH_DIR" -type d -o -type f -name "* tmdb-*" | while IFS= read -r item; do
    # Use grep to filter: must have 'tmdb-' but not '{tmdb-}'
    if echo "$item" | grep -q " tmdb-" && ! echo "$item" | grep -q "{tmdb-"; then
        # Run du -sh on the matched item and print the result
        du -sh "$item"
    fi
done

exit 0
