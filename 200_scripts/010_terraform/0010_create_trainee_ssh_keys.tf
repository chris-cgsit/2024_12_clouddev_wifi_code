resource "tls_private_key" "trainee_keys" {
  for_each = toset(var.trainees)

  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "aws_key_pair" "trainee_key_pairs" {
  for_each   = tls_private_key.trainee_keys
  key_name   = "${each.key}_key"
  public_key = tls_private_key.trainee_keys[each.key].public_key_openssh
}

output "trainee_ssh_keys" {
  value = {
    for name, key in tls_private_key.trainee_keys :
    name => {
      private_key = key.private_key_pem
      public_key  = key.public_key_openssh
    }
  }

  sensitive = true
}


