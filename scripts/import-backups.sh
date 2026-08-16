#!/bin/sh
set -eu

ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
BACKUP_DIR=${1:-"$ROOT/插件备份"}

if [ ! -d "$BACKUP_DIR" ]; then
  printf 'Backup directory not found: %s\n' "$BACKUP_DIR" >&2
  exit 1
fi

mkdir -p "$ROOT/debs"
count=0
skipped=0

for file in "$BACKUP_DIR"/*.deb; do
  [ -f "$file" ] || continue
  name=$(basename "$file")
  destination="$ROOT/debs/$name"
  if [ -e "$destination" ]; then
    printf 'Skip existing: %s\n' "$name"
    skipped=$((skipped + 1))
    continue
  fi
  cp "$file" "$destination"
  printf 'Imported: %s\n' "$name"
  count=$((count + 1))
done

printf 'Imported %s package(s), skipped %s existing package(s).\n' "$count" "$skipped"
