variable "ssh_public_key" {
  type     = string
  nullable = false
}

variable "backend_instance_type" {
  type     = string
  nullable = false
}

variable "backend_instance_disk_gb" {
  type     = number
  nullable = false
}

variable "backend_instance_count" {
  type     = number
  nullable = false
}

data "aws_ami" "debian" {
  most_recent = true
  owners      = ["136693071363"] # Debian

  filter {
    name   = "name"
    values = ["debian-11-amd64-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_instance" "backend" {
  ami             = data.aws_ami.debian.id
  instance_type   = var.backend_instance_type
  key_name        = aws_key_pair.backend.key_name
  security_groups = [aws_security_group.backend.name]
  count           = var.backend_instance_count

  root_block_device {
    volume_type           = "gp2"
    volume_size           = var.backend_instance_disk_gb
    delete_on_termination = true
  }

  tags = {
    Name = "${var.project}-backend-${var.env}-${count.index + 1}"
  }
}

resource "aws_key_pair" "backend" {
  key_name   = "${var.project}-ssh-key-${var.env}"
  public_key = var.ssh_public_key
}

resource "aws_security_group" "backend" {
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
