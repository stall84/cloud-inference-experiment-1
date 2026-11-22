#!/usr/bin/env bash
# Opens the SSH tunnel requested in the project brief:
#   ssh -i <key>.pem -L 11434:localhost:11434 ubuntu@<EC2-PUBLIC-IP>
# Leave this running in its own terminal; Ollama's API is then reachable at
# http://localhost:11434 on this machine for as long as the tunnel is open.
set -euo pipefail
cd "$(dirname "$0")/.."

IP=$(terraform -chdir=terraform output -raw instance_public_ip)
KEY=$(terraform -chdir=terraform output -raw private_key_path)

echo "Tunneling localhost:11434 -> ${IP}:11434 (Ctrl+C to close)"
ssh -i "$KEY" -N -L 11434:localhost:11434 ubuntu@"$IP"
