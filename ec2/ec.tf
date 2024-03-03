# Configure the AWS provider
provider "aws" {
  region = "eu-west-2"
}

variable "key_name" {
  type    = string
  default = "my-key-pair"
}

variable "public_key" {
  type    = string
  default = "~/.ssh/id_rsa.pub"
}

# Create a new security group
resource "aws_security_group" "instance_sg" {
  name        = "instance-security-group"
  description = "Security group for the EC2 instance"

  # Allow inbound SSH traffic from trusted IP range
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["31.94.62.133/32"]
  }

  # Allow inbound HTTP traffic from anywhere
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create a new key pair
resource "aws_key_pair" "my_key_pair" {
  key_name   = var.key_name
  public_key = file(var.public_key)
}

# Define IAM role and policy
resource "aws_iam_role" "instance_role" {
  name = "ec2-instance-role"
  assume_role_policy = jsonencode({
    Version   = "2012-10-17",
    Statement = [{
      Effect    = "Allow",
      Principal = { Service = "ec2.amazonaws.com" },
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_policy" "instance_policy" {
  name   = "ec2-instance-policy"
  policy = jsonencode({
    Version   = "2012-10-17",
    Statement = [{
      Effect    = "Allow",
      Action    = "s3:*",
      Resource  = "*"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "instance_policy_attachment" {
  role       = aws_iam_role.instance_role.name
  policy_arn = aws_iam_policy.instance_policy.arn
  
}

# Create IAM instance profile and associate with IAM role
resource "aws_iam_instance_profile" "instance_profile" {
  name = "ec2-instance-profile"
  role = aws_iam_role.instance_role.name
}

# Launch an EC2 instance
resource "aws_instance" "cyfhotelapp" {
  ami                    = "ami-027d95b1c717e8c5d"
  instance_type          = "t2.micro"
  key_name               = aws_key_pair.my_key_pair.key_name
  security_groups        = [aws_security_group.instance_sg.name]
  iam_instance_profile   = aws_iam_instance_profile.instance_profile.name

  tags = {
    Name = "my-ec2-instance"
  }
}
