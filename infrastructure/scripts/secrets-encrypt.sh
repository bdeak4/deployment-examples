#!/bin/sh

env="$1"
ssh_key="$2"

if [ -z "$env" ] || [ ! -f "$ssh_key" ]; then
  echo "Usage: $0 <env> <ssh_key>"
  exit 1
fi

if ! command -v ansible-vault >/dev/null 2>&1; then
  echo "ansible-vault is required but not installed" >&2
  exit 1
fi

cd -P -- "$(dirname -- "$0")"
cd ..

files="secrets.env secrets.yml"

for file in $files; do
  PRE=$(ansible-vault view --vault-pass-file "$ssh_key" "./env/$env/$file.enc")
  POST=$(cat "./env/$env/$file")

  if [ "$PRE" == "$POST" ]; then
    echo "Restoring unchanged $file"
    mv -f "./env/$env/$file"{.enc,}
  else
    echo "Encrypting $file"
    ansible-vault encrypt --vault-pass-file "$ssh_key" "./env/$env/$file"
    rm "./env/$env/$file.enc"
  fi
done