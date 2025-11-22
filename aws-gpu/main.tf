# Get Ubuntu Deep Learning AMI
data "aws_ami" "gpu_ami" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["Deep Learning AMI *"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

# Simple VPC
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "main" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a" # Specific AZ for better spot capacity
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id
}

resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
}

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.main.id
  route_table_id = aws_route_table.rt.id
}

# Security group
resource "aws_security_group" "gpu_sg" {
  name        = "spot-gpu-sg"
  description = "Security group for GPU spot instance"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.ssh_inbound
  }

  ingress {
    description = "Jupyter"
    from_port   = 8888
    to_port     = 8898
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

# SPOT INSTANCE - 24GB GPU
resource "aws_spot_instance_request" "gpu_spot" {
  count                  = var.instance_type == "spot" ? 1 : 0
  ami                    = data.aws_ami.gpu_ami.id
  instance_type          = "g5.2xlarge" # A10G 24GB GPU
  subnet_id              = aws_subnet.main.id
  vpc_security_group_ids = [aws_security_group.gpu_sg.id]
  key_name               = var.key_name # CHANGE THIS
  availability_zone      = "us-east-1a" # Specific AZ for better spot rates

  # Spot configuration
  spot_type                      = "persistent"
  wait_for_fulfillment           = true
  instance_interruption_behavior = "stop"

  # Set reasonable max price (current spot ~$0.32)
  spot_price = "0.50" # Max you're willing to pay

  associate_public_ip_address = true

  # Storage
  root_block_device {
    volume_size = 100
    volume_type = "gp3"
  }

  tags = {
    Name = "24gb-gpu-spot-cheap"
  }
}

resource "aws_instance" "gpu_ondemand" {
  count = var.instance_type == "ondemand" ? 1 : 0

  ami                    = data.aws_ami.gpu_ami.id
  instance_type          = "g5.2xlarge"
  subnet_id              = aws_subnet.main.id
  vpc_security_group_ids = [aws_security_group.gpu_sg.id]
  key_name               = var.key_name
  availability_zone      = "us-east-1a"

  associate_public_ip_address = true

  root_block_device {
    volume_size = 100
    volume_type = "gp3"
  }

  tags = {
    Name = "24gb-gpu-ondemand"
  }
}
locals {
  instance_public_ip = var.instance_type == "spot" ? (length(aws_spot_instance_request.gpu_spot) > 0 ? aws_spot_instance_request.gpu_spot[0].public_ip : "") : (length(aws_instance.gpu_ondemand) > 0 ? aws_instance.gpu_ondemand[0].public_ip : "")
}
# Outputs
output "public_ip" {
  value = local.instance_public_ip
}

output "ssh_command" {
  value = "ssh -i ~/.ssh/${var.key_name}.pem ubuntu@${local.instance_public_ip}"
}

output "jupyter_url" {
  value = "http://${local.instance_public_ip}:8888"
}

output "instance_type" {
  value = var.instance_type
}
output "cost_estimate" {
  value = var.instance_type == "spot" ? "Spot instance: ~$0.35-0.40/hour" : "On-demand instance: ~$1.20/hour"
}

output "deep_learning_ami_info" {
  value = "Using Deep Learning AMI: ${data.aws_ami.gpu_ami.name}"
}
