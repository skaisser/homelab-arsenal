#!/bin/bash

# rsync-single-move.sh - Script to move files com alto desempenho sem parallel

# Configuração
SRC="/mnt/spiningz/s3/odti1"
DST="/mnt/sfour/odti1"
LOG_DIR="/mnt/big/system/logs/rsync"
LOCKFILE="/tmp/$(basename "$0").lock"
DATE=$(date +%Y%m%d_%H%M%S)
LOGFILE="${LOG_DIR}/rsync_single_${DATE}.log"

# Função de limpeza
cleanup() {
  echo "[*] Limpando e saindo..." | tee -a "$LOGFILE"
  rm -f "$LOCKFILE"
  exit 1
}

# Tratar sinais
trap cleanup SIGHUP SIGINT SIGTERM

# Verificar lockfile
if [ -f "$LOCKFILE" ]; then
  pid=$(cat "$LOCKFILE")
  if ps -p "$pid" > /dev/null 2>&1; then
    echo "[!] Já existe uma instância rodando (PID: $pid)."
    exit 1
  else
    echo "[*] Lockfile encontrado, mas processo morto. Continuando..."
  fi
fi

# Criar lock e pasta de log
echo $$ > "$LOCKFILE"
mkdir -p "$LOG_DIR"

# Verificar se SRC e DST existem
if [ ! -d "$SRC" ]; then
  echo "[!] Diretório de origem $SRC não existe!" | tee -a "$LOGFILE"
  cleanup
fi

if [ ! -d "$DST" ]; then
  echo "[*] Criando diretório de destino $DST..." | tee -a "$LOGFILE"
  mkdir -p "$DST" || { echo "[!] Falha ao criar $DST"; cleanup; }
fi

# Verificar espaço disponível
SRC_SIZE=$(du -s "$SRC" | awk '{print $1}')
DST_AVAIL=$(df -k "$DST" | awk 'NR==2 {print $4}')
if [ $SRC_SIZE -gt $DST_AVAIL ]; then
  echo "[!] Espaço insuficiente. Precisa de ${SRC_SIZE}KB e só tem ${DST_AVAIL}KB." | tee -a "$LOGFILE"
  cleanup
fi

# Início da transferência
echo "[*] Iniciando rsync de $SRC para $DST" | tee -a "$LOGFILE"
echo "[*] Iniciado em $(date)" | tee -a "$LOGFILE"
echo "[*] Log: $LOGFILE" | tee -a "$LOGFILE"

ionice -c 2 -n 0 taskset -c 0-60 rsync -avh \
  --remove-source-files \
  --inplace \
  --no-whole-file \
  --info=progress2 \
  --chown=skaisser:skaisser \
  "$SRC/" "$DST/" >> "$LOGFILE" 2>&1

RSYNC_STATUS=$?

# Limpeza
echo "[*] Removendo diretórios vazios..." | tee -a "$LOGFILE"
find "$SRC" -type d -empty -delete

REMAINING=$(find "$SRC" -type f | wc -l)
if [ $RSYNC_STATUS -eq 0 ] && [ $REMAINING -eq 0 ]; then
  echo "[✓] Transferência concluída com sucesso." | tee -a "$LOGFILE"
else
  echo "[!] Restaram $REMAINING arquivos não movidos. Veja o log para detalhes." | tee -a "$LOGFILE"
fi

echo "[*] Finalizado em $(date)" | tee -a "$LOGFILE"
echo "[*] Duração total: $SECONDS segundos" | tee -a "$LOGFILE"

rm -f "$LOCKFILE"
exit $RSYNC_STATUS
