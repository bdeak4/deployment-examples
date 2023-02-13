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

for file in $(grep -rl " ANSIBLE_VAULT" "./env/$env"); do
  PRE=$(ansible-vault view --vault-pass-file "$ssh_key" "$file.enc")
  POST=$(cat "$file")

  if [ "$PRE" == "$POST" ]; then
    echo "Restoring unchanged $file"
    mv -f "$file"{.enc,}
  else
    echo "Encrypting $file"
    ansible-vault encrypt --vault-pass-file "$ssh_key" "$file"
    rm "$file.enc"
  fi
done