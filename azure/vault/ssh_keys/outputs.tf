output "public_key" {
  value     = tls_private_key._.public_key_openssh
  sensitive = true
}

output "private_key" {
  value     = tls_private_key._.private_key_pem
  sensitive = true
}
