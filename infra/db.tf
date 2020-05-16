resource "aws_db_subnet_group" "db-subnet" {
  name        = "db-subnet"
  description = "RDS subnet group"
  subnet_ids  = [aws_subnet.data_az1.id, aws_subnet.data_az2.id, aws_subnet.data_az3.id]
}

resource "aws_db_instance" "techtest_app" {
  identifier                = "postgres"
  allocated_storage         = 20
  storage_type              = "gp2"
  engine                    = "postgres"
  engine_version            = "9.6.16"
  instance_class            = "db.t2.micro"
  name                      = "app"
  username                  = var.db_username
  password                  = var.db_password
  db_subnet_group_name      = aws_db_subnet_group.db-subnet.id
  final_snapshot_identifier = "foo"
  skip_final_snapshot       = true
  vpc_security_group_ids    = [aws_security_group.allow_http_ssh.id]
}