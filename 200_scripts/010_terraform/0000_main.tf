
provider "aws" {
  profile = "default"
  region  = "eu-central-1"
}

resource "aws_instance" "terraform_test_server" {
  ami           = "ami-0d527b8c289b4af7f"
  instance_type = "t2.micro"

  tags = {
    Name = var.instance_name # TerraformTestInstance
  }
}

output "instance_id" {
  value = aws_instance.terraform_test_server.id
}

output "instance_status" {
  value = aws_instance.terraform_test_server.instance_state
}


