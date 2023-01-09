data "aws_route53_zone" "mydomain" {
  name         = "danail.guru."
  private_zone = false
}




# Output MyDomain Zone ID


output "mydomain_zoneid" {
    description = "The id of the desired Hosted Zone"
    value = data.aws_route53_zone.mydomain.zone_id
  
}

output "mydomain_name" {
    description = "The name of the desired Hosted Zone"
    value = data.aws_route53_zone.mydomain.name
  
}