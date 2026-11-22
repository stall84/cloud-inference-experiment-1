#!/bin/bash
# Cloud-init user_data: installs Ollama and leaves it listening on
# 127.0.0.1:11434 only (the default), since access is always via SSH tunnel.
set -euxo pipefail
exec > >(tee -a /var/log/user-data.log) 2>&1

echo "=== Installing Ollama ==="
curl -fsSL https://ollama.com/install.sh | sh

systemctl enable ollama
systemctl restart ollama

echo "=== Waiting for Ollama API to respond ==="
for i in $(seq 1 30); do
  if curl -fsS http://127.0.0.1:11434/api/version >/dev/null 2>&1; then
    echo "Ollama is up."
    break
  fi
  sleep 2
done

echo "=== user_data complete ==="
