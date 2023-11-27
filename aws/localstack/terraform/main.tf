resource "aws_db_instance" "db_test" {
  allocated_storage    = 10
  db_name              = "mydb"
  engine               = "mysql"
  engine_version       = "5.7"
  instance_class       = "db.t3.micro"
  username             = "keyproco"
  password             = "keyproco"
  parameter_group_name = "test.mysql5.7"
  skip_final_snapshot  = true
}