provider "aws" {
  region     = "us-east-1"
  access_key = "${var.my-access-key}"
  secret_key = "${var.my-secret-key}"
}
terraform {
  backend "s3" {
    bucket = "mybackendtest"
    key    = "prod.tfvars"
    region = "us-east-1"
    dynamodb_table = "terraform-lock"
    encrypt        = true
  }
}

resource "aws_dynamodb_table" "terraform_state_lock" {
  name           = "terraform-lock"
  read_capacity  = 5
  write_capacity = 5
  hash_key       = "LockID"
attribute {
    name = "LockID"
    type = "S"
  }
}

resource "aws_vpc" "myvpc" {
  cidr_block       = "${var.cidr_blockmain}"
  enable_dns_hostnames = "true"
  tags = {
    Name = "${var.vpc_name}"
  }
}

resource "aws_subnet" "mysubnet" {
  vpc_id     = "${aws_vpc.myvpc.id}"
  cidr_block = "${var.cidr_blocksubnet}"

  tags = {
    Name = "${var.subnet_name}"
  }
}
resource "aws_subnet" "mysubnet2" {
  vpc_id     = "${aws_vpc.myvpc.id}"
  cidr_block = "${var.cidr_blocksubnet2}"

  tags = {
    Name = "${var.subnet_name2}"
  }
}

resource "aws_internet_gateway" "mygw" {
  vpc_id = "${aws_vpc.myvpc.id}"

  tags = {
    Name = "${var.gw_name}"
  }
}

resource "aws_route_table" "myroute" {
  vpc_id = "${aws_vpc.myvpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.mygw.id}"
  }
  tags = {
    Name = "${var.tr_name}"
  }
}
resource "aws_route_table_association" "myrouteass" {
  subnet_id      = aws_subnet.mysubnet.id
  route_table_id = aws_route_table.myroute.id
}

