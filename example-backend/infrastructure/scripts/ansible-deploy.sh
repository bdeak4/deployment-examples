#!/bin/sh

env="$1"
ssh_key="$2"

if [ -z "$env" ] || [ ! -f "$ssh_key" ]; then
  echo "Usage: $0 <env> <ssh_key>"
  exit 1
fi

cd -P -- "$(dirname -- "$0")"
cd ..

export ANSIBLE_HOST_KEY_CHECKING=False

ansible-playbook backend.yml -i "./env/$env/hosts.ini" -e "@env/$env/config.vars.yml" \
  --key-file "$ssh_key" --vault-pass-file "$ssh_key" -v