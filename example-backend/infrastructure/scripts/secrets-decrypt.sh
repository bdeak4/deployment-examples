#!/bin/sh

env="$1"
ssh_key="$2"

if [ -z "$env" ] || [ ! -f "$ssh_key" ]; then
  echo "Usage: $0 <env> <ssh_key>"
  exit 1
fi

cd -P -- "$(dirname -- "$0")"
cd ..

files="secrets.env secrets.yml"

for file in $files; do
  echo "Decrypting $file"
  cp "./env/$env/$file"{,.enc}
  ansible-vault decrypt --vault-pass-file "$ssh_key" "./env/$env/$file"
done