resource "aws_db_subnet_group" "rdsdb_group" {
  name       = "rdsdb_group"
  subnet_ids = module.vpc.database_subnets

  tags = local.common_tags
}


resource "aws_db_parameter_group" "general" {
  name   = "rds-pg"
  family = "mysql8.0"

  parameter {
    name  = "character_set_server"
    value = "utf8mb4"
  }

  parameter {
    name  = "character_set_client"
    value = "utf8mb4"
  }
}

resource "aws_db_instance" "rdsdb" {
  identifier = var.db_instance_identifier
  name                 = var.db_name # initial database name
  username             = var.db_username
  password             = var.db_password
  port = 3306
  db_subnet_group_name   = aws_db_subnet_group.rdsdb_group.name
  vpc_security_group_ids = [aws_security_group.rdsdb-sg.id]

  multi_az = true
  allocated_storage    = 20
  max_allocated_storage = 100
  engine               = "mysql"
  engine_version       = "8.0.20"
  instance_class       = "db.t3.large"
  backup_retention_period = 0
  maintenance_window = "Mon:00:00-Mon:03:00"
  backup_window = "03:00-06:00"
  skip_final_snapshot = true
  deletion_protection = false
  performance_insights_enabled = true
  performance_insights_retention_period = 7
    
  
  parameter_group_name =  aws_db_parameter_group.general.name

  tags = local.common_tags
 
}