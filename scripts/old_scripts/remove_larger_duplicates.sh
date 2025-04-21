#!/bin/bash

# Directory to search
SEARCH_DIR="/mnt/stwelve/data/media/movies"

# Check if the search directory exists
if [ ! -d "$SEARCH_DIR" ]; then
    echo "Error: Directory '$SEARCH_DIR' does not exist."
    exit 1
fi

# Find all directories with 'tmdb-' but without '{tmdb-}'
find "$SEARCH_DIR" -maxdepth 1 -type d -name "* tmdb-*" ! -name "*{tmdb-*}" | while IFS= read -r tmdb_dir; do
    # Extract the tmdb ID
    tmdb_id=$(echo "$tmdb_dir" | grep -o "tmdb-[0-9]*$")
    
    # Find the corresponding {tmdb-} folder with the same ID
    curly_tmdb_dir=$(find "$SEARCH_DIR" -maxdepth 1 -type d -name "*{$tmdb_id}" -print -quit)
    
    # If a {tmdb-} counterpart exists
    if [ -n "$curly_tmdb_dir" ] && [ -d "$curly_tmdb_dir" ]; then
        # Get sizes in bytes (du -s for total size, first column is bytes)
        tmdb_size=$(du -s "$tmdb_dir" | cut -f1)
        curly_size=$(du -s "$curly_tmdb_dir" | cut -f1)
        
        # Convert to human-readable for reporting
        tmdb_size_hr=$(du -sh "$tmdb_dir" | cut -f1)
        curly_size_hr=$(du -sh "$curly_tmdb_dir" | cut -f1)

        echo "Found duplicate pair: '$tmdb_dir' ($tmdb_size_hr) and '$curly_tmdb_dir' ($curly_size_hr)"
        
        # Compare sizes and delete the larger one
        if [ "$tmdb_size" -gt "$curly_size" ]; then
            echo "Deleting larger: '$tmdb_dir' ($tmdb_size_hr > $curly_size_hr)"
            rm -rf "$tmdb_dir"
        elif [ "$curly_size" -gt "$tmdb_size" ]; then
            echo "Deleting larger: '$curly_tmdb_dir' ($curly_size_hr > $tmdb_size_hr)"
            rm -rf "$curly_tmdb_dir"
        else
            echo "Sizes are equal ($tmdb_size_hr), keeping '{tmdb-}' version, deleting '$tmdb_dir'"
            rm -rf "$tmdb_dir"
        fi
    fi
done

exit 0
