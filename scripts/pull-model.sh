#!/usr/bin/env bash
# Pulls an Ollama model directly on the remote instance over SSH (not via the
# tunnel - this runs `ollama pull` on the box itself).
# Usage: ./scripts/pull-model.sh llama3.1:8b
set -euo pipefail
cd "$(dirname "$0")/.."

if [ $# -lt 1 ]; then
  echo "Usage: $0 <model-name>   e.g. $0 llama3.1:8b" >&2
  exit 1
fi

IP=$(terraform -chdir=terraform output -raw instance_public_ip)
KEY=$(terraform -chdir=terraform output -raw private_key_path)

ssh -i "$KEY" ubuntu@"$IP" "ollama pull $1"
