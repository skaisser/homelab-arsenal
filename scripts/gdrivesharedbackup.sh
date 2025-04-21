#!/bin/bash

DATE=$(date +%Y%m%d_%H%M%S)
LOG_DIR="/mnt/storage/system/logs/rclone"
mkdir -p "$LOG_DIR"

declare -A accounts=(
  ["gdaccount1"]="/mnt/storage/gdrive/account1/SharedWithMe"
  ["gdaccount2"]="/mnt/storage/gdrive/account2/SharedWithMe"
  ["gdaccount3"]="/mnt/storage/gdrive/account3/SharedWithMe"
)

for remote in "${!accounts[@]}"; do
  DESTINO="${accounts[$remote]}"
  LOGFILE="${LOG_DIR}/rclone_shared_${remote}_${DATE}.log"

  echo "🌀 Starting backup for $remote at $(date)" | tee -a "$LOGFILE"

  rclone copy "$remote": "$DESTINO" \
    --drive-shared-with-me \
    --drive-root-folder-id=root \
    --drive-acknowledge-abuse \
    --transfers=16 \
    --checkers=32 \
    --multi-thread-streams=16 \
    --buffer-size=16M \
    --use-mmap \
    --drive-pacer-min-sleep=10ms \
    --drive-pacer-burst=200 \
    --ignore-existing \
    --retries=10 \
    --low-level-retries=20 \
    --stats=30s \
    --stats-log-level NOTICE \
    --log-file="$LOGFILE" \
    --skip-links \
    --error-on-no-transfer=false

  echo "✅ Finished backup for $remote at $(date)" | tee -a "$LOGFILE"
  echo "" | tee -a "$LOGFILE"
done
