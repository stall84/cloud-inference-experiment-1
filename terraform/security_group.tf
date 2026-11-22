# Tight inbound rules: SSH only, from your allowed IPv4/IPv6 ranges.
# Ollama's API (11434) is intentionally NOT opened here - it stays bound to
# localhost on the instance and is reached only via the SSH tunnel.
resource "aws_security_group" "ssh_only" {
  name        = "${var.project_name}-sg"
  description = "Allow inbound SSH only from the allowed IP ranges; all outbound traffic allowed."
  vpc_id      = data.aws_vpc.default.id

  tags = {
    Name = "${var.project_name}-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "ssh_ipv4" {
  count             = length(var.allowed_ssh_ipv4_cidrs)
  security_group_id = aws_security_group.ssh_only.id
  description       = "SSH from allowed IPv4 range"
  from_port         = 22
  to_port           = 22
  ip_protocol       = "tcp"
  cidr_ipv4         = var.allowed_ssh_ipv4_cidrs[count.index]
}

resource "aws_vpc_security_group_ingress_rule" "ssh_ipv6" {
  count             = length(var.allowed_ssh_ipv6_cidrs)
  security_group_id = aws_security_group.ssh_only.id
  description       = "SSH from allowed IPv6 range"
  from_port         = 22
  to_port           = 22
  ip_protocol       = "tcp"
  cidr_ipv6         = var.allowed_ssh_ipv6_cidrs[count.index]
}

resource "aws_vpc_security_group_egress_rule" "all_ipv4" {
  security_group_id = aws_security_group.ssh_only.id
  description       = "Allow all outbound IPv4 (needed to install Ollama/CUDA packages, pull models, etc.)"
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_vpc_security_group_egress_rule" "all_ipv6" {
  security_group_id = aws_security_group.ssh_only.id
  description       = "Allow all outbound IPv6"
  ip_protocol       = "-1"
  cidr_ipv6         = "::/0"
}
