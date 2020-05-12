resource "aws_db_subnet_group" "db-subnet" {
  name        = "db-subnet"
  description = "RDS subnet group"
  subnet_ids  = [aws_subnet.data_az1.id, aws_subnet.data_az2.id, aws_subnet.data_az3.id]
}

resource "aws_db_instance" "techtest_app" {
  allocated_storage         = 20
  storage_type              = "gp2"
  engine                    = "mysql"
  engine_version            = "5.7"
  instance_class            = "db.t2.micro"
  name                      = "mydb"
  username                  = "foo"
  password                  = "foobarbaz"
  db_subnet_group_name      = aws_db_subnet_group.db-subnet.id
  parameter_group_name      = "default.mysql5.7"
  final_snapshot_identifier = "foo"
  skip_final_snapshot       = true
}