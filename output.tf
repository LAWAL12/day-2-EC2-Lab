output "ec2_public_ip" {
    value = aws_instance.web.public_ip
}
output "tls_private_key" {
  value     = tls_private_key.key.private_key_pem
  sensitive = true
}