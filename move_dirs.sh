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

  # Padroniza nome com no mínimo 4 caracteres
  padded_name="$package_name"
  while [ ${#padded_name} -lt 4 ]; do
    padded_name="${padded_name}_"
  done

  first_two="${padded_name:0:2}"
  third="${padded_name:2:1}"

  if [[ "$third" == "_" || ${#package_name} -lt 4 ]]; then
    middle="_$third"
  else
    middle="${third}_"
  fi

  final_path="$DEST_DIR/$first_two/$middle/$package_name"

  mkdir -p "$final_path"

  # index.json
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

  # metadata.json
  metadata_file="$final_path/metadata.json"
  jq -n \
    --arg name "$package_name" \
    --arg latest "$version" \
    --arg author "Philippe Assis <codephilippe@gmail.com>" \
    --arg homepage "phlow.dev" \
    '{name: $name, author: $author, homepage: $homepage, latest: $latest}' \
    > "$metadata_file"

  mv "$filepath" "$final_path/$filename"

  echo "Movido e indexado: $filename -> $final_path/$filename"
done
