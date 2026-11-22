output "instance_id" {
  description = "EC2 instance ID of the Ollama GPU host."
  value       = aws_instance.ollama.id
}

output "instance_public_ip" {
  description = "Public IP to SSH into (Elastic IP if enabled, otherwise the instance's current public IP)."
  value       = var.enable_eip ? aws_eip.ollama[0].public_ip : aws_instance.ollama.public_ip
}

output "security_group_id" {
  description = "ID of the SSH-only security group, in case you need to add/update IP allowlist rules outside of var changes."
  value       = aws_security_group.ssh_only.id
}

output "private_key_path" {
  description = "Local path to the generated private key (only set when generate_ssh_key = true)."
  value       = var.generate_ssh_key ? local_sensitive_file.private_key[0].filename : null
}

output "ssh_command" {
  description = "Ready-to-run SSH command that also opens the Ollama API tunnel (port 11434)."
  value       = "ssh -i ${var.generate_ssh_key ? local_sensitive_file.private_key[0].filename : var.ssh_public_key_path} -L 11434:localhost:11434 ubuntu@${var.enable_eip ? aws_eip.ollama[0].public_ip : aws_instance.ollama.public_ip}"
}
