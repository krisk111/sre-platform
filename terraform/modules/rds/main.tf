resource "aws_db_subnet_group" "main" {
  name       = "${var.project}-${var.env}-db-subnet-group"
  subnet_ids = var.private_subnet_ids

  tags = {
    Name      = "${var.project}-${var.env}-db-subnet-group"
    Project   = var.project
    Env       = var.env
    ManagedBy = "terraform"
  }
}

resource "aws_security_group" "rds" {
  name        = "${var.project}-${var.env}-rds-sg"
  description = "Security group for PostgreSQL"
  vpc_id      = var.vpc_id

  ingress {
    description = "Postgres within VPC"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name      = "${var.project}-${var.env}-rds-sg"
    Project   = var.project
    Env       = var.env
    ManagedBy = "terraform"
  }
}

resource "aws_db_instance" "main" {
  identifier            = "${var.project}-${var.env}-postgres"
  engine                = "postgres"
  engine_version        = var.engine_version
  instance_class        = var.instance_class
  allocated_storage     = var.allocated_storage
  max_allocated_storage = var.max_allocated_storage
  db_name               = var.db_name
  username              = var.db_username
  password              = var.db_password
  port                  = 5432

  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.rds.id]

  publicly_accessible     = false
  multi_az                = false
  storage_encrypted       = true
  backup_retention_period = 7
  skip_final_snapshot     = true
  deletion_protection     = false

  tags = {
    Name      = "${var.project}-${var.env}-postgres"
    Project   = var.project
    Env       = var.env
    ManagedBy = "terraform"
  }
}