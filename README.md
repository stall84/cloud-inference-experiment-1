# cloud-inference-experiment-1

Prototype infrastructure for running open-weight LLM inference "locally, but
on cloud infrastructure" — you provision a GPU box on AWS, run
[Ollama](https://ollama.com) on it, and talk to it only over an SSH tunnel.
No inference traffic, prompts, or context ever goes to a third-party AI
provider; the only exposed network surface is SSH, locked to your IP(s).

## Architecture

- **Region:** `us-west-2` (Oregon) — hardcoded/validated for every resource.
- **Compute:** 1x `g6.2xlarge` (1x NVIDIA L4 GPU, 8 vCPU, 32 GiB RAM).
- **AMI:** AWS "Deep Learning Base AMI with Single CUDA (Ubuntu 24.04)",
  resolved dynamically via its public SSM parameter so you always get the
  latest build (CUDA/drivers preinstalled, so no driver install step needed).
- **Storage:** 150 GB `gp3` encrypted root volume (adjustable 150–200 GB).
- **Networking:** Default VPC/subnet (kept intentionally simple — no
  dedicated VPC). Security group allows **inbound TCP/22 only**, from your
  IPv4 `/32` and your IPv6 `/64` subnet. All other inbound is blocked —
  Ollama's API port (11434) is never exposed publicly; it's reached only via
  an SSH local-port-forward tunnel.
- **Elastic IP:** enabled by default so the instance keeps the same public
  IP across stop/start (small hourly AWS charge while allocated).
- **SSH key:** Terraform generates a dedicated RSA 4096 keypair and writes
  the private key locally as `terraform/cloud-inference-experiment-1-key.pem`
  (0600 permissions, gitignored).
- **Ollama install:** done via `user_data` (cloud-init) on first boot —
  installs Ollama, enables it as a systemd service, binds to
  `127.0.0.1:11434` (the default).

## Prerequisites

- [Terraform](https://developer.hashicorp.com/terraform) >= 1.5
- An AWS account/IAM user with permissions to manage EC2, security groups,
  and key pairs in `us-west-2`
- `curl` and `jq` (used by the helper scripts)

AWS CLI is **not** required — Terraform's AWS provider talks to AWS directly.

## Setup

1. **Credentials.** Copy `.env.example` to `.env` and fill in your AWS
   access key/secret (`.env` is gitignored):

   ```bash
   cp .env.example .env
   # edit .env with your AWS_ACCESS_KEY_ID / AWS_SECRET_ACCESS_KEY
   ```

2. **IP allowlist.** Copy `terraform/terraform.tfvars.example` to
   `terraform/terraform.tfvars`. It's pre-filled with the IPs you gave me
   (IPv4 `172.56.82.159/32`, IPv6 `/64` subnet containing
   `2607:fb91:4f8c:458e:...`). Run `./scripts/get-my-ip.sh` any time to check
   whether your IP has changed and needs updating.

   ```bash
   cp terraform/terraform.tfvars.example terraform/terraform.tfvars
   ```

3. **Provision:**

   ```bash
   ./scripts/tf.sh init
   ./scripts/tf.sh plan
   ./scripts/tf.sh apply
   ```

   `scripts/tf.sh` just sources `.env` and runs `terraform -chdir=terraform`,
   so you can also run `terraform` directly from inside `terraform/` if you
   export the AWS env vars yourself.

4. **Wait for first boot.** Ollama installation happens via `user_data` and
   typically takes 1–3 minutes after the instance reaches "running". You can
   tail progress with:

   ```bash
   ssh -i terraform/cloud-inference-experiment-1-key.pem ubuntu@$(./scripts/tf.sh output -raw instance_public_ip) \
     'tail -f /var/log/user-data.log'
   ```

## Connecting

Open the tunnel (matches the exact command from the brief):

```bash
./scripts/ssh-tunnel.sh
# equivalent to:
# ssh -i terraform/cloud-inference-experiment-1-key.pem -L 11434:localhost:11434 ubuntu@<EC2-PUBLIC-IP>
```

Leave that running in its own terminal. While it's open, Ollama's API is
reachable at `http://localhost:11434` on this Mac.

Pull a model (runs over a plain SSH exec, not the tunnel):

```bash
./scripts/pull-model.sh llama3.1:8b
```

Send a prompt through the tunnel:

```bash
./scripts/chat.sh llama3.1:8b "Explain gp3 vs gp2 EBS volumes in two sentences."
```

Or use `curl`/any Ollama-compatible client directly against
`http://localhost:11434` while the tunnel is open.

## Updating the SSH allowlist

Home/mobile IPs change. If SSH stops connecting:

```bash
./scripts/get-my-ip.sh
# update allowed_ssh_ipv4_cidrs / allowed_ssh_ipv6_cidrs in terraform/terraform.tfvars
./scripts/tf.sh apply
```

This only updates the security group rules in place — it does not
recreate the instance.

## Cost notes

- `g6.2xlarge` bills by the hour while **running** — stop it when not in use
  (`aws ec2 stop-instances` or the console). The root EBS volume and the
  Elastic IP continue to bill while stopped (EBS per GB-month; EIP a small
  hourly rate while unattached-but-allocated... note an EIP attached to a
  *stopped* instance is also billed).
- To tear everything down: `./scripts/tf.sh destroy`.

## Notes / things to double-check

- **IPv6 allowlist tradeoff:** your IPv6 address looked like a
  privacy/rotating address, so the security group allows your `/64` subnet
  rather than the exact `/128`. This is less strict than a single address
  but much less likely to silently lock you out. Tighten it in
  `terraform.tfvars` if you'd rather have the exact `/128`.
- **Default VPC:** this uses your account's default VPC/subnet in
  `us-west-2` to keep the footprint small. If your account doesn't have a
  default VPC (some older/locked-down accounts don't), say so and I'll add a
  minimal dedicated VPC instead.
- **g6.2xlarge capacity:** on-demand GPU instance capacity can occasionally
  be constrained in a given AZ. If `apply` fails with an insufficient
  capacity error, re-run `apply` (Terraform will pick whichever default
  subnet/AZ it resolved) or let me know and I'll add an AZ override variable.
- **TypeScript app:** not built yet — the brief said "possibly", and Ollama's
  own HTTP API plus the `curl`/`jq`-based `scripts/chat.sh` already satisfies
  "send prompts over SSH" for a small-footprint prototype. Say the word if
  you'd like a small TypeScript CLI/client added on top later.
