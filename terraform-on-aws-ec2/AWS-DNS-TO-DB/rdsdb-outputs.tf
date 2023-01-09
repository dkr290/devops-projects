output "rds_address" {
    description = "The hostname of the RDS instance"
    value = aws_db_instance.rdsdb.address
  
}

output "allocated_storage" {
    description = "The amount of allocated storage"
    value = aws_db_instance.rdsdb.allocated_storage
  
}

output "availability_zone" {
    description = "The availability zone of the instance"
    value = aws_db_instance.rdsdb.availability_zone
  
}

output "database_name" {
    description = "The database name"
    value = aws_db_instance.rdsdb.name
  
}