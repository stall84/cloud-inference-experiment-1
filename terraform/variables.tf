variable "aws_region" {
  description = "AWS region for every resource. This project is pinned to us-west-2 (Oregon)."
  type        = string
  default     = "us-west-2"

  validation {
    condition     = var.aws_region == "us-west-2"
    error_message = "This project is intentionally pinned to us-west-2 (Oregon). Change this validation if you really need another region."
  }
}

variable "project_name" {
  description = "Name prefix used for tagging and resource names."
  type        = string
  default     = "cloud-inference-experiment-1"
}

variable "instance_type" {
  description = "EC2 instance type for the Ollama GPU host."
  type        = string
  default     = "g6.2xlarge"
}

variable "root_volume_gb" {
  description = "Size (GB) of the gp3 root volume. Must be between 150 and 200 per project requirements."
  type        = number
  default     = 150

  validation {
    condition     = var.root_volume_gb >= 150 && var.root_volume_gb <= 200
    error_message = "root_volume_gb must be between 150 and 200 (gp3, GB)."
  }
}

variable "allowed_ssh_ipv4_cidrs" {
  description = "IPv4 CIDR blocks allowed to SSH (port 22) into the instance. Keep this as narrow as possible."
  type        = list(string)
  default     = ["172.56.82.159/32"]
}

variable "allowed_ssh_ipv6_cidrs" {
  description = "IPv6 CIDR blocks allowed to SSH (port 22) into the instance. Defaults to the /64 subnet containing your current IPv6 address, since single IPv6 addresses often rotate."
  type        = list(string)
  default     = ["2607:fb91:4f8c:458e::/64"]
}

variable "enable_eip" {
  description = "Whether to allocate and associate an Elastic IP so the instance keeps the same public IP across stop/start. Note: AWS bills a small hourly charge for an EIP while it is allocated but not attached to a running instance."
  type        = bool
  default     = true
}

variable "key_pair_name" {
  description = "Name of the AWS key pair to create/use for SSH access."
  type        = string
  default     = "cloud-inference-experiment-1-key"
}

variable "generate_ssh_key" {
  description = "If true, Terraform generates a brand-new SSH keypair and saves the private key locally. If false, var.ssh_public_key_path must point at an existing public key."
  type        = bool
  default     = true
}

variable "ssh_public_key_path" {
  description = "Path to an existing public key file. Only used when generate_ssh_key is false."
  type        = string
  default     = ""
}
