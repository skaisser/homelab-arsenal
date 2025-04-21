#!/bin/bash

# Set your rclone remote path and destination path
REMOTE="b2:bkpkaisser/odti3/"
DESTINATION="/mnt/user/secure/Woult/"

# Get list of all directories from the remote
rclone lsd "$REMOTE" | grep -i "woult" | while read -r line; do
  # Extract the directory name, handling spaces and special characters
  DIR_NAME=$(echo "$line" | awk '{for (i=5; i<=NF; i++) printf "%s ", $i; print ""}' | sed 's/ *$//')

  # Print a message indicating which folder is being downloaded
  echo "Downloading folder: $DIR_NAME"
  
  # Download the folder, handling spaces and special characters
  rclone copy "$REMOTE$DIR_NAME" "$DESTINATION/$DIR_NAME" --progress --transfers=33 --stats=10s --bwlimit=off
  
done

echo "Download complete."
