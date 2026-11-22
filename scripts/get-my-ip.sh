#!/usr/bin/env bash
# Prints your current public IPv4/IPv6 so you can update
# terraform/terraform.tfvars (allowed_ssh_ipv4_cidrs / allowed_ssh_ipv6_cidrs)
# if your home IP changes and SSH access stops working.
set -uo pipefail

ipv4=$(curl -s -4 --max-time 5 https://ifconfig.co 2>/dev/null || curl -s --max-time 5 https://api.ipify.org 2>/dev/null || echo "unavailable")
ipv6=$(curl -s -6 --max-time 5 https://ifconfig.co 2>/dev/null || echo "unavailable")

echo "Current IPv4: ${ipv4}  ->  ${ipv4}/32"
echo "Current IPv6: ${ipv6}"

echo ""
echo "If these differ from terraform/terraform.tfvars, update:"
echo '  allowed_ssh_ipv4_cidrs = ["'"${ipv4}"'/32"]'
echo "then run: ./scripts/tf.sh apply"
