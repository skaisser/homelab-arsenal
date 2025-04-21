#!/bin/bash
# media-workflow.sh - Wrapper script to ensure sequential execution of download and sorting
# This script first downloads files from Put.io and then sorts them

# Define variables
DATE=$(date +%Y%m%d_%H%M%S)
LOG_DIR="/mnt/storage/system/logs/$(basename "$0" .sh)"
LOGFILE="${LOG_DIR}/$(basename "$0" .sh)_${DATE}.log"
LOCKFILE="/tmp/$(basename "$0").lock"

# Paths to the scripts
DOWNLOADER_SCRIPT="/mnt/storage/system/scripts/putio-downloader.sh"
SORTER_SCRIPT="/mnt/storage/system/scripts/filebot-organizer.sh"

# Variables to track if any files were processed
ARQUIVOS_BAIXADOS=0
ARQUIVOS_PROCESSADOS=0

# Function for cleanup on exit
cleanup() {
  rm -f "$LOCKFILE"
  echo "🛑 Wrapper script interrompido às $(date)" | tee -a "$LOGFILE"
  exit 1
}

# Capture signals for proper cleanup
trap cleanup SIGHUP SIGINT SIGTERM

# Check if already running
if [ -f "$LOCKFILE" ]; then
  pid=$(cat "$LOCKFILE")
  if ps -p "$pid" > /dev/null 2>&1; then
    echo "⚠️ Outra instância já está em execução (PID: $pid). Saindo."
    exit 1
  else
    echo "🔄 Arquivo de lock encontrado, mas processo não está rodando. Continuando..."
  fi
fi

# Create lock file
echo $$ > "$LOCKFILE"

# Create log directory if it doesn't exist
mkdir -p "$LOG_DIR"
echo "🌀 Iniciando workflow de mídia às $(date)" | tee -a "$LOGFILE"

# Step 1: Run the downloader script
echo "📥 Executando script de download..." | tee -a "$LOGFILE"
"$DOWNLOADER_SCRIPT"
DOWNLOAD_STATUS=$?

# We'll check for recent logs from the individual scripts to determine if they had activity

if [ $DOWNLOAD_STATUS -ne 0 ]; then
  echo "❌ Script de download falhou com status $DOWNLOAD_STATUS. Abortando workflow." | tee -a "$LOGFILE"
  cleanup
fi

echo "✅ Download concluído com sucesso." | tee -a "$LOGFILE"

# Step 2: Run the sorter script
echo "🔄 Executando script de organização..." | tee -a "$LOGFILE"
"$SORTER_SCRIPT"
SORT_STATUS=$?



if [ $SORT_STATUS -ne 0 ]; then
  echo "❌ Script de organização falhou com status $SORT_STATUS." | tee -a "$LOGFILE"
  # We don't exit here as the download was successful
else
  echo "✅ Organização concluída com sucesso. $ARQUIVOS_PROCESSADOS arquivo(s) processado(s)." | tee -a "$LOGFILE"
fi

# Summary
echo "📊 Resumo do workflow:" | tee -a "$LOGFILE"
[ $DOWNLOAD_STATUS -eq 0 ] && echo "✅ Download: Processado com sucesso" || echo "❌ Download: Falha no processamento"
[ $SORT_STATUS -eq 0 ] && echo "✅ Organização: Processado com sucesso" || echo "❌ Organização: Falha no processamento"
echo "✅ Workflow finalizado às $(date)" | tee -a "$LOGFILE"

# Remove lock file
rm -f "$LOCKFILE"

# Check for recent logs from the individual scripts (within the last 15 minutes)
DOWNLOADER_LOG_DIR="/mnt/storage/system/logs/putio-downloader"
SORTER_LOG_DIR="/mnt/storage/system/logs/filebot-organizer"
CURRENT_TIME=$(date +%s)
FIFTEEN_MINUTES_AGO=$((CURRENT_TIME - 900)) # 15 minutes = 900 seconds

# Function to check if there are recent logs
check_recent_logs() {
  local log_dir="$1"
  local found=0
  
  if [ -d "$log_dir" ]; then
    # Find the most recent log file
    local recent_log=$(find "$log_dir" -name "*.log" -type f -mmin -15 | head -1)
    if [ -n "$recent_log" ]; then
      found=1
    fi
  fi
  
  echo $found
}

# Check if either script kept its log
DOWNLOADER_KEPT_LOG=$(check_recent_logs "$DOWNLOADER_LOG_DIR")
SORTER_KEPT_LOG=$(check_recent_logs "$SORTER_LOG_DIR")

# Remove our log if neither script kept their logs and both scripts were successful
if [ "$DOWNLOADER_KEPT_LOG" -eq 0 ] && [ "$SORTER_KEPT_LOG" -eq 0 ] && [ $DOWNLOAD_STATUS -eq 0 ] && [ $SORT_STATUS -eq 0 ]; then
  echo "ℹ️ Nenhum log recente encontrado dos scripts individuais. Removendo arquivo de log..."
  rm -f "$LOGFILE"
else
  echo "ℹ️ Mantendo log devido à atividade detectada ou erros"
fi

exit 0
