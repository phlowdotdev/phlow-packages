#!/bin/bash

RAW_DIR="./raw"
DEST_DIR="./packages"

mkdir -p "$DEST_DIR"

for filepath in "$RAW_DIR"/*.tar.gz; do
  [ -e "$filepath" ] || continue

  filename=$(basename "$filepath")
  base_name="${filename%.tar.gz}"

  # Extrai nome e versão do padrão: nome-versão.tar.gz
  package_name="${base_name%-*}"
  version="${base_name##*-}"

  # Padroniza para no mínimo 4 caracteres
  padded=$(printf "%-4s" "$package_name" | tr ' ' '_')

  prefix="${padded:0:2}"
  middle="${padded:2:2}"

  final_path="$DEST_DIR/$prefix/$middle/$package_name"

  mkdir -p "$final_path"

  # Cria ou atualiza index.json
  new_entry=$(jq -n \
    --arg name "$package_name" \
    --arg version "$version" \
    --arg repository "https://github.com/lowcarboncode/phlow-packages" \
    '{name: $name, version: $version, repository: $repository}')

  index_file="$final_path/index.json"

  if [ -f "$index_file" ]; then
    tmp=$(mktemp)
    jq ". += [$new_entry]" "$index_file" > "$tmp" && mv "$tmp" "$index_file"
  else
    echo "[$new_entry]" > "$index_file"
  fi

  # Cria metadata.json
  metadata_file="$final_path/metadata.json"
  jq -n \
    --arg name "$package_name" \
    --arg latest "$version" \
    --arg author "Philippe Assis <codephilippe@gmail.com>" \
    --arg homepage "phlow.dev" \
    '{name: $name, author: $author, homepage: $homepage, latest: $latest}' \
    > "$metadata_file"

  # Move o tar.gz
  mv "$filepath" "$final_path/$filename"

  echo "Movido e indexado: $filename -> $final_path/$filename"
done
