#!/bin/bash

# Directory to search
SEARCH_DIR="/mnt/mainpool/media/movies/"

# Check if the search directory exists
if [ ! -d "$SEARCH_DIR" ]; then
    echo "Error: Directory '$SEARCH_DIR' does not exist."
    exit 1
fi

# Find all directories with 'tmdb-' in their name
find "$SEARCH_DIR" -maxdepth 1 -type d -name "* tmdb-*" | while IFS= read -r tmdb_dir; do
    # Extract the base name (without path) and the tmdb ID
    base_name=$(basename "$tmdb_dir")
    tmdb_id=$(echo "$base_name" | grep -o "tmdb-[0-9]*$")
    # Get the movie name part before the tmdb-ID, normalize spaces
    movie_name=$(echo "$base_name" | sed "s/ $tmdb_id$//" | sed 's/  */ /g')

    # Construct the {tmdb-} version with original spacing and a hyphenated variant
    curly_tmdb_dir="$SEARCH_DIR/$movie_name {$tmdb_id}"
    # Convert spaces to hyphens, but preserve the year in parentheses
    movie_name_hyphen=$(echo "$movie_name" | sed 's/ \([0-9]\{4\}\)$/ (\1)/; s/ /-/g')
    curly_tmdb_dir_hyphen="$SEARCH_DIR/$movie_name_hyphen {$tmdb_id}"

    # Check if either {tmdb-} version exists
    if [ -d "$curly_tmdb_dir" ] || [ -d "$curly_tmdb_dir_hyphen" ]; then
        # Use the existing one for reporting
        target_curly_dir=$( [ -d "$curly_tmdb_dir" ] && echo "$curly_tmdb_dir" || echo "$curly_tmdb_dir_hyphen" )
        
        # Check if the tmdb- directory is not empty
        if [ -n "$(ls -A "$tmdb_dir")" ]; then
            echo "Found duplicate: '$tmdb_dir' (not empty) and '$target_curly_dir'"
            echo "Deleting: '$tmdb_dir'"
            rm -rf "$tmdb_dir"
        else
            echo "Skipping: '$tmdb_dir' is empty, keeping '$target_curly_dir'"
        fi
    fi
done

exit 0
