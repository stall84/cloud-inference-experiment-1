resource "aws_instance" "ollama-remote" {
  ami                         = data.aws_ssm_parameter.ubuntu_dlami.value
  instance_type               = var.instance_type
  key_name                    = aws_key_pair.this.key_name
  subnet_id                   = data.aws_subnets.default.ids[0]
  vpc_security_group_ids      = [aws_security_group.ssh_only.id]
  associate_public_ip_address = true

  root_block_device {
    volume_type           = "gp3"
    volume_size           = var.root_volume_gb
    delete_on_termination = true
    encrypted             = true
  }

  user_data                   = file("${path.module}/user_data.sh.tpl")
  user_data_replace_on_change = true

  tags = {
    Name = "${var.project_name}-ollama-remote"
  }
}

resource "aws_eip" "ollama-remote" {
  count    = var.enable_eip ? 1 : 0
  domain   = "vpc"
  instance = aws_instance.ollama-remote.id

  tags = {
    Name = "${var.project_name}-ollama-remote-eip"
  }
}
