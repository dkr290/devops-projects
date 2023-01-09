data "aws_availability_zones" "myazones" {
  all_availability_zones = true

  filter {
    name   = "opt-in-status"
    values = ["opt-in-not-required"]
  }
}




data "aws_ec2_instance_type_offering" "my_inst_type" {

  for_each = toset(data.aws_availability_zones.myazones.names)
  filter {
    name   = "instance-type"
    values = ["t3.micro"]
  }

  filter {
    name = "location"
    values = [each.key]
  }

  location_type = "availability-zone"
}
