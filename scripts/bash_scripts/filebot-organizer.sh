#!/bin/bash
# media-sorter.sh - Script para organizar arquivos de mídia usando filebot
# Define as Variaveis
DATE=$(date +%Y%m%d_%H%M%S)
LOG_DIR="/mnt/big/system/logs/$(basename "$0" .sh)"
LOGFILE="${LOG_DIR}/$(basename "$0" .sh)_${DATE}.log"
LOCKFILE="/tmp/$(basename "$0").lock"
# Variável para rastrear se algum arquivo foi processado
ARQUIVOS_PROCESSADOS=0
# Arrays para armazenar caminhos de novos arquivos processados
NOVOS_FILMES=()
NOVAS_SERIES=()

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
  local espaco_minimo=5  # GB

  if [ -d "$diretorio" ]; then
    espaco_livre=$(df -BG "$diretorio" | awk 'NR==2 {print $4}' | sed 's/G//')
    if [ "$espaco_livre" -lt "$espaco_minimo" ]; then
      echo "⛔ ALERTA: Menos de ${espaco_minimo}GB disponível em $diretorio (${espaco_livre}GB)" | tee -a "$LOGFILE"
      return 1
    fi
  fi
  return 0
}

# Função para executar comandos dentro do container
executar_no_container() {
  docker exec filebot bash -c "$1"
  return $?
}

# Função para organizar arquivos de filme soltos em pastas individuais
organizar_filmes_soltos() {
  local diretorio="$1"
  local arquivos_organizados=0

  echo "🔍 Verificando arquivos de filme soltos em $diretorio..." | tee -a "$LOGFILE"

  # Verificar se o diretório existe dentro do container
  if ! executar_no_container "test -d \"$diretorio\""; then
    echo "⚠️ Diretório $diretorio não encontrado dentro do container." | tee -a "$LOGFILE"
    return 1
  fi

  # Obter lista de arquivos de vídeo na raiz do diretório
  # Extensões comuns de vídeo
  local video_files=$(executar_no_container "find \"$diretorio\" -maxdepth 1 -type f -regextype posix-extended -regex '.*\.(mkv|mp4|avi|mov|wmv|m4v)' -printf '%f\n'")

  if [ -z "$video_files" ]; then
    echo "ℹ️ Nenhum arquivo de vídeo solto encontrado em $diretorio" | tee -a "$LOGFILE"
    return 0
  fi

  echo "$video_files" | while read -r filename; do
    if [ -n "$filename" ]; then
      # Extrair nome do arquivo sem extensão
      local basename="${filename%.*}"
      local folder_path="$diretorio/$basename"

      echo "📁 Criando pasta para $filename..." | tee -a "$LOGFILE"

      # Criar pasta com o nome do arquivo
      executar_no_container "mkdir -p \"$folder_path\""

      if [ $? -eq 0 ]; then
        # Mover arquivo para dentro da pasta
        executar_no_container "mv \"$diretorio/$filename\" \"$folder_path/\""

        if [ $? -eq 0 ]; then
          echo "✅ Arquivo $filename movido para pasta $basename" | tee -a "$LOGFILE"
          arquivos_organizados=$((arquivos_organizados + 1))
        else
          echo "❌ Falha ao mover $filename para pasta $basename" | tee -a "$LOGFILE"
        fi
      else
        echo "❌ Falha ao criar pasta $basename" | tee -a "$LOGFILE"
      fi
    fi
  done

  echo "🔄 Organização concluída. $arquivos_organizados arquivo(s) organizados em pastas." | tee -a "$LOGFILE"
  return 0
}

# Função para processar mídia
processar_midia() {
  local tipo="$1"
  local origem="$2"
  local destino="$3"
  local arquivos_movidos=0

  # Verificar se o diretório de origem existe
  if ! executar_no_container "test -d \"$origem\""; then
    echo "⚠️ Diretório de origem $origem não encontrado dentro do container." | tee -a "$LOGFILE"
    return 1
  fi

  # Verificar se o diretório de destino existe, se não, tentar criar
  if ! executar_no_container "test -d \"$destino\""; then
    echo "⚠️ Diretório de destino $destino não encontrado dentro do container. Tentando criar..." | tee -a "$LOGFILE"
    executar_no_container "mkdir -p \"$destino\""
    if [ $? -ne 0 ]; then
      echo "❌ Falha ao criar diretório de destino $destino" | tee -a "$LOGFILE"
      return 1
    fi
  fi

  # Verificar espaço em disco no destino
  # Usar docker exec para verificar espaço dentro do container
  espaco_livre=$(executar_no_container "df -BG \"$destino\" | awk 'NR==2 {print \$4}' | sed 's/G//'")
  local espaco_minimo=5  # GB

  if [ -z "$espaco_livre" ] || [ "$espaco_livre" -lt "$espaco_minimo" ]; then
    echo "⛔ ALERTA: Menos de ${espaco_minimo}GB disponível em $destino (${espaco_livre}GB)" | tee -a "$LOGFILE"
    return 1
  fi

  # Verificar se há arquivos para processar usando docker exec
  arquivos_antes=$(executar_no_container "find \"$origem\" -type f | wc -l")
  if [ "$arquivos_antes" -eq 0 ]; then
    echo "ℹ️ Nenhum arquivo para processar em $origem" | tee -a "$LOGFILE"
    return 0
  fi

  echo "📂 Processando $tipo de $origem para $destino" | tee -a "$LOGFILE"

  # Listar diretórios antes do processamento para comparação posterior
  diretorios_antes=$(executar_no_container "find \"$destino\" -type d -mindepth 1 -maxdepth 1")

  # Executar filebot
  docker exec filebot /opt/filebot/filebot \
    -script fn:amc \
    --output "$destino" \
    --action move \
    --conflict skip \
    -non-strict "$origem" \
    --log info \
    --lang en \
    --def subtitles=pb \
    --def encoding=utf-8 \
    --def minFileSize=50 \
    --def minLengthMS=300000 \
    --def artwork=y \
    --def unsorted=y \
    --def clean=y \
    --def music=n \
    --def deleteAfterExtract=y \
    --def skipExtract=n \
    --def extractFolder=y \
    --def movieFormat="{ ~plex.id }" \
    --def seriesFormat="{ ~plex.id }" \
    >> "$LOGFILE" 2>&1

  if [ $? -ne 0 ]; then
    echo "❌ Erro ao processar $tipo. Verifique o log para mais detalhes." | tee -a "$LOGFILE"
    return 1
  fi

  # Contar arquivos após o processamento
  arquivos_depois=$(executar_no_container "find \"$origem\" -type f | wc -l")
  arquivos_movidos=$((arquivos_antes - arquivos_depois))

  # Atualizar contador global
  ARQUIVOS_PROCESSADOS=$((ARQUIVOS_PROCESSADOS + arquivos_movidos))

  # Listar diretórios após o processamento para identificar os novos
  diretorios_depois=$(executar_no_container "find \"$destino\" -type d -mindepth 1 -maxdepth 1")

  # Identificar os novos diretórios criados (aqueles que estão em diretorios_depois mas não em diretorios_antes)
  while read -r dir; do
    if ! echo "$diretorios_antes" | grep -q "^$dir$"; then
      # Adicionar à lista apropriada
      if [ "$tipo" = "Filmes" ]; then
        NOVOS_FILMES+=("$dir")
      elif [ "$tipo" = "Séries" ]; then
        NOVAS_SERIES+=("$dir")
      fi
    fi
  done <<< "$diretorios_depois"

  echo "✅ Processamento de $tipo concluído. $arquivos_movidos arquivo(s) processado(s)." | tee -a "$LOGFILE"

  return 0
}

# Verificar se o container filebot está rodando
docker ps | grep -q "filebot"
if [ $? -ne 0 ]; then
  echo "❌ Container filebot não está rodando. Abortando." | tee -a "$LOGFILE"
  cleanup
fi

# Organizar filmes soltos
organizar_filmes_soltos "/data/torrents/movies"

# Processar Filmes
processar_midia "Filmes" "/data/torrents/movies" "/data/media/movies"
FILMES_STATUS=$?

# Processar Séries
processar_midia "Séries" "/data/torrents/tv" "/data/media/tv"
SERIES_STATUS=$?

# Baixar legendas em português para os arquivos processados
if [ "$ARQUIVOS_PROCESSADOS" -gt 0 ]; then
  echo "🔤 Baixando legendas em português para os arquivos processados..." | tee -a "$LOGFILE"

  # Baixar legendas para filmes
  if [ $FILMES_STATUS -eq 0 ] && [ ${#NOVOS_FILMES[@]} -gt 0 ]; then
    echo "🔤 Baixando legendas para ${#NOVOS_FILMES[@]} filme(s) novo(s)..." | tee -a "$LOGFILE"
    for diretorio in "${NOVOS_FILMES[@]}"; do
      dir_name=$(basename "$diretorio")
      echo "🔍 Buscando legendas para: $dir_name" | tee -a "$LOGFILE"

      # Baixar legendas para o diretório inteiro
      docker exec filebot /opt/filebot/filebot -get-subtitles -r "$diretorio" -non-strict \
        --lang pb --output srt --encoding utf-8  \
        >> "$LOGFILE" 2>&1

      if [ $? -eq 0 ]; then
        echo "  ✅ Legendas baixadas com sucesso para $dir_name" | tee -a "$LOGFILE"
      else
        echo "  ⚠️ Falha ao baixar legendas para $dir_name" | tee -a "$LOGFILE"
      fi
    done

    echo "✅ Processamento de legendas para filmes concluído" | tee -a "$LOGFILE"
  else
    echo "ℹ️ Nenhum filme novo para baixar legendas" | tee -a "$LOGFILE"
  fi

  # Baixar legendas para séries
  if [ $SERIES_STATUS -eq 0 ] && [ ${#NOVAS_SERIES[@]} -gt 0 ]; then
    echo "🔤 Baixando legendas para ${#NOVAS_SERIES[@]} série(s) nova(s)..." | tee -a "$LOGFILE"
    for diretorio in "${NOVAS_SERIES[@]}"; do
      dir_name=$(basename "$diretorio")
      echo "🔍 Buscando legendas para: $dir_name" | tee -a "$LOGFILE"

      # Baixar legendas para o diretório inteiro
      docker exec filebot /opt/filebot/filebot -get-subtitles -r "$diretorio" -non-strict \
        --lang pb --output srt --encoding utf-8  \
        >> "$LOGFILE" 2>&1

      if [ $? -eq 0 ]; then
        echo "  ✅ Legendas baixadas com sucesso para $dir_name" | tee -a "$LOGFILE"
      else
        echo "  ⚠️ Falha ao baixar legendas para $dir_name" | tee -a "$LOGFILE"
      fi
    done

    echo "✅ Processamento de legendas para séries concluído" | tee -a "$LOGFILE"
  else
    echo "ℹ️ Nenhuma série nova para baixar legendas" | tee -a "$LOGFILE"
  fi
fi

# Corrigir permissões de todos os arquivos processados
if [ "$ARQUIVOS_PROCESSADOS" -gt 0 ]; then
  echo "🛠️ Corrigindo permissões em todos os diretórios de mídia..." | tee -a "$LOGFILE"

  # Corrigir permissões para filmes
  if [ $FILMES_STATUS -eq 0 ]; then
    echo "🔧 Ajustando permissões em Dos Filmes..." | tee -a "$LOGFILE"
    # Definir o proprietário para todos os arquivos e diretórios
    chown -R skaisser:skaisser "/mnt/stwelve/data/media/movies"

    if [ $? -eq 0 ]; then
      echo "✅ Permissões de filmes corrigidas com sucesso" | tee -a "$LOGFILE"
    else
      echo "⚠️ Falha ao corrigir permissões de filmes" | tee -a "$LOGFILE"
    fi
  fi

  # Corrigir permissões para séries
  if [ $SERIES_STATUS -eq 0 ]; then
    echo "🔧 Ajustando permissões das Series..." | tee -a "$LOGFILE"
    # Definir o proprietário para todos os arquivos e diretórios
    chown -R skaisser:skaisser "/mnt/stwelve/data/media/tv"

    if [ $? -eq 0 ]; then
      echo "✅ Permissões de séries corrigidas com sucesso" | tee -a "$LOGFILE"
    else
      echo "⚠️ Falha ao corrigir permissões de séries" | tee -a "$LOGFILE"
    fi
  fi
fi

# Resumo final
echo "📊 Resumo do processamento:" | tee -a "$LOGFILE"
[ $FILMES_STATUS -eq 0 ] && echo "✅ Filmes: Processado com sucesso" || echo "❌ Filmes: Falha no processamento"
[ $SERIES_STATUS -eq 0 ] && echo "✅ Séries: Processado com sucesso" || echo "❌ Séries: Falha no processamento"
echo "✅ Finalizado às $(date)" | tee -a "$LOGFILE"

# Remover arquivo de lock
rm -f "$LOCKFILE"

# Remover o arquivo de log se nenhum arquivo foi processado
if [ "$ARQUIVOS_PROCESSADOS" -eq 0 ] && [ $FILMES_STATUS -eq 0 ] && [ $SERIES_STATUS -eq 0 ]; then
  echo "ℹ️ Nenhum arquivo processado nesta execução. Removendo arquivo de log..."
  rm -f "$LOGFILE"
fi

exit 0
