resource "tls_private_key" "_" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "private_key_output" {
  sensitive_content = tls_private_key._.private_key_pem
  filename          = "${path.module}/keys/private_key.pem"
}

resource "local_file" "public_key_output" {
  sensitive_content = tls_private_key._.public_key_openssh
  filename          = "${path.module}/keys/public_key.pem"
}
