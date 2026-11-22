# Generates a new keypair by default. The private key is written locally
# (gitignored, 0600) and never stored anywhere except Terraform state + disk.
resource "tls_private_key" "this" {
  count     = var.generate_ssh_key ? 1 : 0
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_sensitive_file" "private_key" {
  count           = var.generate_ssh_key ? 1 : 0
  content         = tls_private_key.this[0].private_key_pem
  filename        = "${path.module}/${var.key_pair_name}.pem"
  file_permission = "0600"
}

resource "aws_key_pair" "this" {
  key_name   = var.key_pair_name
  public_key = var.generate_ssh_key ? tls_private_key.this[0].public_key_openssh : file(var.ssh_public_key_path)
}
