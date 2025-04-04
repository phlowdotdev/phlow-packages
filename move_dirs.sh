#!/bin/bash

RAW_DIR="./raw"
DEST_DIR="./packages"

# Garante que o diretório de destino exista
mkdir -p "$DEST_DIR"

# Itera sobre os diretórios em RAW_DIR
for dir in "$RAW_DIR"/*/; do
  # Remove trailing slash e pega o nome do diretório
  dir=${dir%*/}
  dir_name=$(basename "$dir")

  # Caminho base de destino
  current_path="$DEST_DIR"

  # Cria a estrutura m/e/u/d/i/r
  for (( i=0; i<${#dir_name}; i++ )); do
    letter="${dir_name:$i:1}"
    current_path="$current_path/$letter"
    mkdir -p "$current_path"
  done

  # Move o diretório original para dentro do caminho final
  mv "$RAW_DIR/$dir_name" "$current_path/$dir_name"

  echo "Movido: $RAW_DIR/$dir_name -> $current_path/$dir_name"
done
