#!/bin/bash

DATE=$(date +%Y%m%d_%H%M%S)
LOG_DIR="/mnt/big/system/logs/rclone"
LOGFILE="${LOG_DIR}/rclone_shared_copy_${DATE}.log"

mkdir -p "$LOG_DIR"

echo "🌀 Starting shared-with-me Google Drive backup at $(date)" | tee -a "$LOGFILE"

rclone copy gdkaisser: /mnt/big/gdrive/kaisser/CompartilhadosComigo \
  --drive-shared-with-me \
  --drive-root-folder-id=root \
  --transfers=16 \
  --checkers=32 \
  --multi-thread-streams=16 \
  --buffer-size=16M \
  --use-mmap \
  --drive-pacer-min-sleep=10ms \
  --drive-pacer-burst=200 \
  --stats=1s \
  --log-file="$LOGFILE"

echo "✅ Done at $(date)" | tee -a "$LOGFILE"
