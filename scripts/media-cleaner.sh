#!/bin/bash

# media-cleaner.sh
# Uso: ./media-cleaner.sh [--dry-run] /caminho/da/pasta

DRY_RUN=false
CAMINHO_INICIAL=""

# Verifica se o primeiro argumento é --dry-run
if [ "$1" == "--dry-run" ]; then
  DRY_RUN=true
  CAMINHO_INICIAL="$2"
else
  CAMINHO_INICIAL="$1"
fi

if [ -z "$CAMINHO_INICIAL" ]; then
  echo "❌ Caminho inicial não informado."
  echo "👉 Uso: ./media-cleaner.sh [--dry-run] /mnt/media/data/media/movies"
  exit 1
fi

echo "🧹 Limpando arquivos desnecessários em: $CAMINHO_INICIAL"
echo "📂 Mantendo: .mkv .mp4 .avi .mov .wmv .m4v .srt .ass .sub .iso"

FIND_CMD='find "'"$CAMINHO_INICIAL"'" -type f ! \( -iname "*.mkv" -o -iname "*.mp4" -o -iname "*.avi" -o -iname "*.mov" -o -iname "*.wmv" -o -iname "*.m4v" -o -iname "*.srt" -o -iname "*.ass" -o -iname "*.sub" -o -iname "*.iso" \)'

if $DRY_RUN; then
  echo "🔍 Modo de simulação ativado (nenhum arquivo será deletado)"
  eval "$FIND_CMD -print"
else
  eval "$FIND_CMD -print -delete"
  echo "✅ Limpeza concluída."
fi
