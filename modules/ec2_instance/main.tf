data "aws_vpc" "default" {
  default = true
  count   = var.vpc_id == null ? 1 : 0
}

data "aws_subnets" "default" {
  count = var.vpc_id == null ? 1 : 0
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default[0].id]
  }
}

data "aws_subnet" "default" {
  count = var.subnet_id == null ? 1 : 0
  id    = data.aws_subnets.default[0].ids[0]
}


resource "aws_security_group" "this" {
  name        = "${var.name}-sg"
  description = "${var.name}-sg"
  vpc_id      = var.vpc_id != null ? var.vpc_id : data.aws_vpc.default[0].id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 51820
    to_port     = 51820
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = var.tags
}


data "aws_ami" "al2023" {
  count = var.ami == null ? 1 : 0

  most_recent = true

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-kernel-6.1-x86_64"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }

  owners = ["137112412989"] # Amazon Linux AMI official account
}


resource "aws_instance" "this" {
  ami                         = var.ami != null ? var.ami : data.aws_ami.al2023[0].id
  instance_type               = var.instance_type
  key_name                    = var.key_name
  associate_public_ip_address = true
  subnet_id                   = var.subnet_id != null ? var.subnet_id : data.aws_subnet.default[0].id
  vpc_security_group_ids      = [aws_security_group.this.id]
  user_data                   = var.user_data
  tags                        = var.tags
}

# resource "aws_eip" "this" {
#   instance = aws_instance.this.id
#   tags     = var.tags
# }
