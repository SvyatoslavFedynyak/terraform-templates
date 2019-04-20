provider "aws" {
  region = "eu-central-1"
}
resource "aws_vpc" "elk_vpc" {
    cidr_block = "192.168.144.0/24"

  tags 
  {
      Name = "elk_vpc"
      aim = "elk for aws"
  }
}

resource "aws_subnet" "public_subnet" {
  cidr_block = "192.168.144.0/25"
  vpc_id = "${aws_vpc.elk_vpc.id}"
  availability_zone = "${var.availability_zone}"
  map_public_ip_on_launch = true

  tags 
  {
      Name = "public_subnet"
      aim = "elk for aws"
  }
  depends_on = [
      "aws_vpc.elk_vpc"
  ]
}

resource "aws_subnet" "private_subnet" {
  cidr_block = "192.168.144.128/25"
  vpc_id = "${aws_vpc.elk_vpc.id}"
  availability_zone = "${var.availability_zone}"
  map_public_ip_on_launch = false

  tags 
  {
     Name = "private_subnet"
      aim = "elk for aws"
  }
  depends_on = [
      "aws_vpc.elk_vpc"
  ]
}

resource "aws_security_group" "basic_web_sg" {
  name = "Basiv web security group"
  vpc_id = "${aws_vpc.elk_vpc.id}"
  description = "Security group with main web protocols white list"
  ingress = {
  from_port = 22
  to_port = 22
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  }

  ingress = {
  from_port = 80
  to_port = 80
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  }

  ingress = {
  from_port = 443
  to_port = 443
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  }

  ingress = {
  from_port = 8080
  to_port = 8080
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  }

  ingress = {
  from_port = 3306
  to_port = 3306
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  }


  egress = {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags 
  {
      Name = "basic_web_sg"
      aim = "elk for aws"
  }
  depends_on = [
      "aws_vpc.elk_vpc"
  ]
}

resource "aws_internet_gateway" "gw" {
  vpc_id = "${aws_vpc.elk_vpc.id}"

  tags = {
    Name = "elk ig"
    aim = "elk for aws"
  }
}

resource "aws_route_table" "elk_rt" {
  vpc_id = "${aws_vpc.elk_vpc.id}"
    

tags 
  {
      Name = "elk_rt"
      aim = "elk for aws"
  }
}
resource "aws_network_interface" "nginx_server_ni" {
  subnet_id = "${aws_subnet.public_subnet.id}"
  security_groups = [
      "${aws_security_group.basic_web_sg.id}"
  ]
  tags 
  {
      Name = "nginx_server_ni"
      aim = "elk for aws"
  }
  depends_on = 
  [
      "aws_subnet.public_subnet"
  ]
}

resource "aws_instance" "nginx_server" {
  instance_type = "t2.micro"
  ami = "${var.ami}"
  key_name = "${var.key}"
  instance_initiated_shutdown_behavior = "stop"

  network_interface = {
    network_interface_id = "${aws_network_interface.nginx_server_ni.id}"
    device_index = 0
    delete_on_termination = false
  }
  volume_tags = {
    size = 10
    Name = "nginx_server_volume"
    aim = "elk for aws"
  }
  tags 
  {
      Name = "nginx_server"
      aim = "elk for aws"
  }
  depends_on =
  [
      "aws_network_interface.nginx_server_ni"
  ]
}