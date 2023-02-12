#!/bin/sh

env="$1"

if [ -z "$env" ]; then
  echo "Usage: $0 <env>"
  exit 1
fi

if ! command -v terraform >/dev/null 2>&1; then
  echo "terraform is required but not installed" >&2
  exit 1
fi

cd -P -- "$(dirname -- "$0")"
cd ..

# ignore specific files for other environments
find . -name '*.*.tf' -not -name "*.$env.*" -exec rename .tf .tfign {} +
trap "find . -name '*.*.tfign' -exec rename .tfign .tf {} +" EXIT

terraform init -backend-config "./env/$env/managed/state-backend.tfvars" -reconfigure
terraform apply -var-file "./env/$env/config.tfvars"
