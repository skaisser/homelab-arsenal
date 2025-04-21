#!/bin/bash

DATE=$(date +%Y%m%d_%H%M%S)
LOG_DIR="/mnt/storage/system/logs"
LOGFILE="${LOG_DIR}/rsync_odti2_migration_${DATE}.log"

mkdir -p "$LOG_DIR"

echo "🌀 Iniciando migração de /mnt/data/source/archive para /mnt/data/destination/archive às $(date)" | tee -a "$LOGFILE"

rsync -aHAX --remove-source-files \
  --info=progress2 --stats \
  --inplace --no-whole-file \
  /mnt/data/source/archive/ /mnt/data/destination/archive/ \
  | tee -a "$LOGFILE"

echo "✅ Migração finalizada às $(date)" | tee -a "$LOGFILE"
