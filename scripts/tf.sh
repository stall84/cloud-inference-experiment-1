#!/usr/bin/env bash
# Loads AWS credentials from .env (gitignored) and runs terraform in ./terraform.
# Usage: ./scripts/tf.sh plan
#        ./scripts/tf.sh apply
#        ./scripts/tf.sh output -raw instance_public_ip
set -euo pipefail
cd "$(dirname "$0")/.."

if [ -f .env ]; then
  set -a
  # shellcheck disable=SC1091
  source .env
  set +a
else
  echo "Warning: .env not found. Copy .env.example to .env and fill in AWS credentials first." >&2
fi

exec terraform -chdir=terraform "$@"
