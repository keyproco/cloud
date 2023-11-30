
resource "aws_security_group" "allow_app" {
  name        = "allow_app"
  description = "Allow SSH inbound traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "SSH from anywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "HTTP from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "ICMP from anywhere"
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    description = "Allow HTTPS TCP traffic"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "allow_app_anywhere"
  }

}

data "aws_subnet" "sn_app_a" {
  filter {
    name   = "tag:Name"
    values = ["sn-web-B"]
  }
  depends_on = [aws_subnet.sn_dasboto]
}


resource "aws_iam_instance_profile" "dev-resources-iam-profile" {
  name = "ec2_profile"
  role = aws_iam_role.dev-resources-iam-role.name
}
resource "aws_iam_role" "dev-resources-iam-role" {
  name               = "dev-ssm-role"
  description        = "The role for the developer resources EC2"
  assume_role_policy = <<EOF
{
                        "Version": "2012-10-17",
                            "Statement": {
                            "Effect": "Allow",
                            "Principal": {"Service": "ec2.amazonaws.com"},
                            "Action": "sts:AssumeRole"
                            }
                        }
                        EOF
  tags = {
    stack = "test"
  }
}
resource "aws_iam_role_policy_attachment" "dev-resources-ssm-policy" {
  role       = aws_iam_role.dev-resources-iam-role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}



resource "aws_ssm_parameter" "wordpress" {
  for_each = var.db_parameters

  name  = "/app/wordpress/${each.key}"
  type  = each.value.is_password ? "SecureString" : "String"
  value = each.value.value
}

resource "aws_instance" "app" {
  ami                         = "ami-0302f42a44bf53a45"
  instance_type               = "t2.micro"
  associate_public_ip_address = true
  subnet_id                   = data.aws_subnet.sn_app_a.id
  key_name                    = "ias-dasbotoapp-kp"

  tags = {
    Name = "wordpress-app"
  }

  iam_instance_profile = aws_iam_instance_profile.dev-resources-iam-profile.name
  user_data = templatefile("./scripts/user_data_script.sh", {
    DBEndpoint     = aws_ssm_parameter.wordpress["DBEndpoint"].value
    DBRootPassword = aws_ssm_parameter.wordpress["DBRootPassword"].value
    DBPassword     = aws_ssm_parameter.wordpress["DBRootPassword"].value
    DBName         = aws_ssm_parameter.wordpress["DBName"].value
    DBUser         = aws_ssm_parameter.wordpress["DBUser"].value
  })





  vpc_security_group_ids = [aws_security_group.allow_app.id]
}
