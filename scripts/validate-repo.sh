#!/bin/sh
set -eu

ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT"

if [ ! -f Packages ]; then
  printf 'Missing generated file: Packages\n' >&2
  exit 1
fi

for file in Packages.gz Packages.bz2 Release; do
  if [ ! -s "$file" ]; then
    printf 'Missing generated file: %s\n' "$file" >&2
    exit 1
  fi
done

gzip -t Packages.gz
bzip2 -t Packages.bz2

if ! awk '
  /^Package: / { packages++ }
  /^Filename: / { files++ }
  END { if (packages != files) exit 1 }
' Packages; then
  printf '%s\n' 'Every indexed package must have a Filename field.' >&2
  exit 1
fi

awk '/^Filename: / { print substr($0, 11) }' Packages | while IFS= read -r path; do
  [ -z "$path" ] && continue
  case "$path" in
    debs/*)
      [ -f "$path" ] || {
        printf 'Indexed file is missing: %s\n' "$path" >&2
        exit 1
      }
      ;;
    *)
      printf 'Unexpected package path: %s\n' "$path" >&2
      exit 1
      ;;
  esac
done

printf '%s\n' 'Repository metadata is valid.'
