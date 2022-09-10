provider "aws" {
  region = "us-east-1"
}

resource "aws_key_pair" "deployer" {
    key_name   = "terraform-platzi"
    public_key = var.public_key
}

resource "aws_instance" "platzi_instance" {
  ami = var.ami_id
  instance_type = var.instance_type
  tags = var.tags
  security_groups = ["${aws_security_group.ssh_conection.name}"]
  key_name = aws_key_pair.deployer.key_name
}

resource "aws_security_group" "ssh_conection" {
  name        = var.sg_name
  description = "Allow TLS inbound traffic"

  dynamic "ingress" {
    for_each = var.ingress_rules
    content {
      from_port        = ingress.value.from_port
      to_port          = ingress.value.to_port
      protocol         = ingress.value.protocol
      cidr_blocks      = ingress.value.cidr_blocks
    }
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow_tls"
  }
}