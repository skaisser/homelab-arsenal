#!/bin/bash
# putio-downloader.sh - Script para baixar arquivos do Put.io usando rclone
# Define as Variaveis
DATE=$(date +%Y%m%d_%H%M%S)
LOG_DIR="/mnt/storage/system/logs/$(basename "$0" .sh)"
LOGFILE="${LOG_DIR}/$(basename "$0" .sh)_${DATE}.log"
LOCKFILE="/tmp/$(basename "$0").lock"
# Variável para rastrear se algum arquivo foi baixado
ARQUIVOS_BAIXADOS=0

# Função para limpeza ao sair
cleanup() {
  rm -f "$LOCKFILE"
  echo "🛑 Script interrompido às $(date)" | tee -a "$LOGFILE"
  exit 1
}

# Capturar sinais para limpeza adequada
trap cleanup SIGHUP SIGINT SIGTERM

# Verificar se já está em execução
if [ -f "$LOCKFILE" ]; then
  pid=$(cat "$LOCKFILE")
  if ps -p "$pid" > /dev/null 2>&1; then
    echo "⚠️ Outra instância já está em execução (PID: $pid). Saindo." | tee -a "$LOGFILE"
    exit 1
  else
    echo "🔄 Arquivo de lock encontrado, mas processo não está rodando. Continuando..." | tee -a "$LOGFILE"
  fi
fi

# Criar arquivo de lock
echo $$ > "$LOCKFILE"

# Criar diretório de logs se não existir
mkdir -p "$LOG_DIR"
echo "🌀 Iniciando processamento às $(date)" | tee -a "$LOGFILE"

# Função para verificar espaço em disco
verificar_espaco() {
  local diretorio="$1"
  local espaco_minimo=10  # GB

  if [ -d "$diretorio" ]; then
    espaco_livre=$(df -BG "$diretorio" | awk 'NR==2 {print $4}' | sed 's/G//')
    if [ "$espaco_livre" -lt "$espaco_minimo" ]; then
      echo "⛔ ALERTA: Menos de ${espaco_minimo}GB disponível em $diretorio (${espaco_livre}GB)" | tee -a "$LOGFILE"
      return 1
    fi
  fi
  return 0
}

# Função para baixar arquivos do Put.io
baixar_de_putio() {
  local tipo="$1"
  local origem="$2"
  local destino="$3"
  local arquivos_antes=0
  local arquivos_depois=0
  local arquivos_baixados=0

  echo "📥 Baixando $tipo de $origem para $destino" | tee -a "$LOGFILE"

  # Verificar se o diretório de destino existe
  if [ ! -d "$destino" ]; then
    echo "⚠️ Diretório de destino $destino não encontrado. Tentando criar..." | tee -a "$LOGFILE"
    mkdir -p "$destino"
    if [ $? -ne 0 ]; then
      echo "❌ Falha ao criar diretório de destino $destino" | tee -a "$LOGFILE"
      return 1
    fi
  fi

  # Verificar espaço em disco no destino
  verificar_espaco "$destino" || return 1

  # Contar arquivos antes do download
  arquivos_antes=$(find "$destino" -type f | wc -l)

  # Executar rclone para baixar os arquivos
  rclone move "$origem" "$destino" \
    --transfers=16 \
    --checkers=32 \
    --multi-thread-streams=16 \
    --buffer-size=16G \
    --use-mmap \
    --stats=30s \
    --progress \
    >> "$LOGFILE" 2>&1

  if [ $? -ne 0 ]; then
    echo "❌ Erro ao baixar $tipo. Verifique o log para mais detalhes." | tee -a "$LOGFILE"
    return 1
  fi

  # Contar arquivos após o download
  arquivos_depois=$(find "$destino" -type f | wc -l)
  arquivos_baixados=$((arquivos_depois - arquivos_antes))

  # Atualizar contador global
  ARQUIVOS_BAIXADOS=$((ARQUIVOS_BAIXADOS + arquivos_baixados))

  echo "✅ Download de $tipo concluído. $arquivos_baixados arquivo(s) baixado(s)." | tee -a "$LOGFILE"

  return 0
}

# Baixar Filmes do Put.io
baixar_de_putio "Filmes" "putio:/download/movies" "/mnt/media/data/torrents/movies"
FILMES_STATUS=$?

# Baixar Séries do Put.io
baixar_de_putio "Séries" "putio:/download/tv" "/mnt/media/data/torrents/tv"
SERIES_STATUS=$?

# Resumo final
echo "📊 Resumo do processamento:" | tee -a "$LOGFILE"
[ $FILMES_STATUS -eq 0 ] && echo "✅ Filmes: Processado com sucesso" || echo "❌ Filmes: Falha no processamento"
[ $SERIES_STATUS -eq 0 ] && echo "✅ Séries: Processado com sucesso" || echo "❌ Séries: Falha no processamento"
echo "✅ Finalizado às $(date)" | tee -a "$LOGFILE"

# Remover arquivo de lock
rm -f "$LOCKFILE"

# Remover o arquivo de log se nenhum arquivo foi baixado
if [ "$ARQUIVOS_BAIXADOS" -eq 0 ] && [ $FILMES_STATUS -eq 0 ] && [ $SERIES_STATUS -eq 0 ]; then
  echo "ℹ️ Nenhum arquivo baixado nesta execução. Removendo arquivo de log..."
  rm -f "$LOGFILE"
fi

exit 0
