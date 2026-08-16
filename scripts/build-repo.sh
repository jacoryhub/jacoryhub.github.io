#!/bin/sh
set -eu

ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT"

if ! command -v dpkg-scanpackages >/dev/null 2>&1; then
  printf '%s\n' 'dpkg-scanpackages is required. Install dpkg-dev (Debian/Ubuntu: apt-get install dpkg-dev).' >&2
  exit 1
fi

mkdir -p debs

# -m keeps every package version, which is useful while testing upgrades.
dpkg-scanpackages -m debs /dev/null > Packages
gzip -n -9 -c Packages > Packages.gz
bzip2 -9 -c Packages > Packages.bz2

DATE=$(LC_ALL=C date -u '+%a, %d %b %Y %H:%M:%S %z')
ARCHES=$(awk -F': ' '/^Architecture: / { print $2 }' Packages | sort -u | tr '\n' ' ' | sed 's/[[:space:]]*$//')
[ -n "$ARCHES" ] || ARCHES=iphoneos-arm64e
{
  printf 'Origin: Personal roothide repo\n'
  printf 'Label: Personal roothide repo\n'
  printf 'Suite: stable\n'
  printf 'Codename: ios\n'
  printf 'Architectures: %s\n' "$ARCHES"
  printf 'Components: main\n'
  printf 'Description: Personal APT repository\n'
  printf 'Date: %s\n' "$DATE"
  printf 'SHA256:\n'
  for file in Packages Packages.gz Packages.bz2; do
    size=$(wc -c < "$file" | tr -d ' ')
    if command -v sha256sum >/dev/null 2>&1; then
      hash=$(sha256sum "$file" | awk '{print $1}')
    else
      hash=$(shasum -a 256 "$file" | awk '{print $1}')
    fi
    printf ' %s %s %s\n' "$hash" "$size" "$file"
  done
} > Release

printf 'Built Packages, Packages.gz, Packages.bz2 and Release in %s\n' "$ROOT"
