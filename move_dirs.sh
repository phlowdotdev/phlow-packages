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

  # Garante ao menos 4 caracteres
  padded_name=$(printf "%-4s" "$package_name" | tr ' ' '_')

  prefix="${padded_name:0:2}"
  middle="_${padded_name:2:1}"
  final_dir="$package_name"
  final_path="$DEST_DIR/$prefix/$middle/$final_dir"

  mkdir -p "$final_path"

  # Monta JSON
  new_entry=$(jq -n \
    --arg name "$package_name" \
    --arg version "$version" \
    --arg repository "https://github.com/lowcarboncode/phlow" \
    '{name: $name, version: $version, repository: $repository}')

  index_file="$final_path/index"

  if [ -f "$index_file" ]; then
    tmp=$(mktemp)
    jq ". += [$new_entry]" "$index_file" > "$tmp" && mv "$tmp" "$index_file"
  else
    echo "[$new_entry]" > "$index_file"
  fi

  mv "$filepath" "$final_path/$filename"

  echo "Movido e indexado: $filename -> $final_path/$filename"
done
