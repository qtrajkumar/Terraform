resource "aws_security_group" "database" {
  vpc_id = local.vpc_id
  name   = "mysql"
  ingress {
    description = "TLS from VPC"
    from_port   = 3306
    to_port     = 3306
    protocol    = local.tcp
    cidr_blocks = [var.aws_subnet_info.vpc_cidr]
  }
  tags = {
    Name = "mysql"
  }
  depends_on = [
    aws_subnet.subnets
  ]
}

data "aws_subnets" "db" {
  filter {
    name   = "tag:Name"
    values = var.aws_subnet_info.db_subnets
  }
  filter {
    name   = "vpc-id"
    values = [local.vpc_id]
  }
  depends_on = [
    aws_subnet.subnets
  ]
}

resource "aws_db_subnet_group" "dbsubnet" {
  name       = "dbsubnet"
  subnet_ids = data.aws_subnets.db.ids

  tags = {
    Name = "My DB subnet group"
  }
  depends_on = [
    aws_subnet.subnets
  ]
}

resource "aws_db_instance" "myemply" {
  allocated_storage      = 20
  db_name                = "myemply"
  engine                 = "mysql"
  engine_version         = "8.0.27"
  instance_class         = "db.t3.micro"
  username               = "admin"
  password               = "rootroot"
  publicly_accessible    = false
  vpc_security_group_ids = [aws_security_group.database.id]
  skip_final_snapshot    = true
  depends_on = [
    aws_db_subnet_group.dbsubnet,
    aws_security_group.database
  ]
}