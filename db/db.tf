provider "aws" {
  region = "eu-west-2"
}

resource "aws_db_subnet_group" "example" {
  name       = "example-db-subnet-group"
  subnet_ids = var.subnet_ids
}

resource "aws_db_instance" "example" {
  allocated_storage    = var.allocated_storage
  engine               = "postgres"
  engine_version       = var.engine_version
  instance_class       = var.instance_class
  identifier           = var.identifier
  username             = var.username
  password             = var.password
  skip_final_snapshot  = true

  db_subnet_group_name = aws_db_subnet_group.example.name

  tags = {
    Name = "Example RDS Instance"
  }
}
