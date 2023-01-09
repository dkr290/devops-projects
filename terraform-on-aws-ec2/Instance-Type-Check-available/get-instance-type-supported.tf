


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



output "output_verify" {
    value = {for key,  item in data.aws_ec2_instance_type_offering.my_inst_type: 
    
    key => item.instance_type if length(item.instance_type) != 0}
}


output "output_verify-keys" {
    value = keys({for key,  item in data.aws_ec2_instance_type_offering.my_inst_type: 
    
    key => item.instance_type if length(item.instance_type) != 0})
}

output "output_verify-keys-values" {
    value = keys({for key,  item in data.aws_ec2_instance_type_offering.my_inst_type: 
    
    key => item.instance_type if length(item.instance_type) != 0})[0]
}