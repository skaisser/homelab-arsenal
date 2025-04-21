# Set the directory to the provided argument
directory=$1

# Check if the provided directory exists
if [ ! -d "$directory" ]; then
    echo "Directory not found!"
    exit 1
fi

# Loop through all subdirectories in the provided directory
for folder in "$directory"/*; do
    if [ -d "$folder" ]; then
        # Calculate the total size of the folder in MB
        folder_size=$(du -sm "$folder" | cut -f1)

        # Check if the folder size is less than 100MB
        if [ "$folder_size" -lt 100 ]; then
            echo "Deleting folder: $folder (Size: ${folder_size}MB)"
            rm -rf "$folder"
        fi
    fi
done

echo "Cleanup completed."
