# Get Ubuntu Deep Learning AMI

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical's owner ID

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}

# SPOT INSTANCE - 24GB GPU
resource "aws_spot_instance_request" "gpu_spot" {
  count = var.instance_type == "spot" ? 1 : 0
  ami   = data.aws_ami.ubuntu.id
  #instance_type          = "g5.xlarge" # A10G 24GB GPU 4CPU
  instance_type          = "g5.2xlarge" # A10G 24GB GPU 4CPU
  subnet_id              = element(aws_subnet.main[*].id, random_integer.az.result)
  vpc_security_group_ids = [aws_security_group.gpu_sg.id]
  key_name               = var.key_name # CHANGE THIS
  user_data_base64       = base64encode(templatefile("${path.module}/user-data.sh", {}))

  # Spot configuration
  spot_type                      = "persistent"
  wait_for_fulfillment           = true
  instance_interruption_behavior = "stop"

  # Set reasonable max price (current spot ~$0.32)
  spot_price = "0.51" # Max you're willing to pay

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
resource "random_integer" "az" {
  min = 0
  max = 2
}

# resource "aws_instance" "gpu_ondemand" {
#   count = var.instance_type == "ondemand" ? 1 : 0
#
#   ami                    = data.aws_ami.ubuntu.id
#   instance_type          = "g5.xlarge"
#   subnet_id              = aws_subnet.main.id
#   vpc_security_group_ids = [aws_security_group.gpu_sg.id]
#   key_name               = var.key_name
#   availability_zone      = "us-east-1a"
#
#   associate_public_ip_address = true
#
#   root_block_device {
#     volume_size = 100
#     volume_type = "gp3"
#   }
#
#   tags = {
#     Name = "24gb-gpu-ondemand"
#   }
# }



