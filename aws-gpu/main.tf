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

# SPOT INSTANCE - 24GB GPU
resource "aws_spot_instance_request" "gpu_spot" {
  count                  = var.instance_type == "spot" ? 1 : 0
  ami                    = data.aws_ami.gpu_ami.id
  instance_type          = "g5.xlarge" # A10G 24GB GPU 4CPU
  subnet_id              = aws_subnet.main.id
  vpc_security_group_ids = [aws_security_group.gpu_sg.id]
  key_name               = var.key_name # CHANGE THIS
  availability_zone      = "us-east-1a" # Specific AZ for better spot rates

  # Spot configuration
  spot_type                      = "persistent"
  wait_for_fulfillment           = true
  instance_interruption_behavior = "stop"

  # Set reasonable max price (current spot ~$0.32)
  spot_price = "0.39" # Max you're willing to pay

  associate_public_ip_address = true

  # Storage
  root_block_device {
    volume_size = 100
    volume_type = "gp3"
  }

  tags = {
    Name = "gpu-spot-training-node"
    Env  = "dev"
  }
}

resource "aws_instance" "gpu_ondemand" {
  count = var.instance_type == "ondemand" ? 1 : 0

  ami                    = data.aws_ami.gpu_ami.id
  instance_type          = "g5.xlarge"
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



