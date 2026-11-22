#!/usr/bin/env bash
# Sends a single prompt to Ollama over the SSH tunnel (run ssh-tunnel.sh in
# another terminal first). Requires `jq`.
# Usage: ./scripts/chat.sh llama3.1:8b "What is the capital of Oregon?"
set -euo pipefail

if [ $# -lt 2 ]; then
  echo "Usage: $0 <model-name> <prompt text>" >&2
  exit 1
fi

model="$1"
shift
prompt="$*"

curl -s http://localhost:11434/api/generate \
  -d "$(jq -n --arg m "$model" --arg p "$prompt" '{model: $m, prompt: $p, stream: false}')" \
  | jq -r '.response'
