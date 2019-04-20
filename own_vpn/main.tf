provider "aws" {
  region = "eu-central-1"
}

            ### Networking ###

resource "aws_vpc" "vpn_vpc" {
    cidr_block = "192.168.144.0/24"

  tags 
  {
      Name = "vpn_vpc"
      ita_group = "Lv-378"
      owner = "svyatoslav"
      note = "non_academy_task"
      aim = "aws_study"
  }
}

resource "aws_subnet" "public_subnet" {
  cidr_block = "192.168.144.0/25"
  vpc_id = "${aws_vpc.vpn_vpc.id}"
  availability_zone = "${var.availability_zone}"
  map_public_ip_on_launch = true

  tags 
  {
      Name = "public_subnet"
      ita_group = "Lv-378"
      owner = "svyatoslav"
      note = "non_academy_task"
      aim = "aws_study"
  }
  depends_on = [
      "aws_vpc.vpn_vpc"
  ]
}

resource "aws_subnet" "private_subnet" {
  cidr_block = "192.168.144.128/25"
  vpc_id = "${aws_vpc.vpn_vpc.id}"
  availability_zone = "${var.availability_zone}"
  map_public_ip_on_launch = false

  tags 
  {
      Name = "private_subnet"
      ita_group = "Lv-378"
      owner = "svyatoslav"
      note = "non_academy_task"
      aim = "aws_study"
  }
  depends_on = [
      "aws_vpc.vpn_vpc"
  ]
}

resource "aws_security_group" "all_traphic_sg" {
  vpc_id = "${aws_vpc.vpn_vpc.id}"
  description = "All trafic allow"
  ingress = {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress = {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "all_traphic_sg"
    ita_group = "Lv-378"
    owner = "svyatoslav"
    note = "non_academy_task"
    aim = "aws_study"
  }
}

resource "aws_route_table" "default_rt" {
  vpc_id = "${aws_vpc.vpn_vpc.id}"

tags = {
    Name = "default_rt"
    ita_group = "Lv-378"
    owner = "svyatoslav"
    note = "non_academy_task"
    aim = "aws_study"
  }
}

resource "aws_network_interface" "vpn_host_ni" {
  subnet_id = "${aws_subnet.public_subnet.id}"
  security_groups = [
      "${aws_security_group.all_traphic_sg.id}"
  ]
  tags = {
    Name = "vpn_host_ni"
    ita_group = "Lv-378"
    owner = "svyatoslav"
    note = "non_academy_task"
    aim = "aws_study"
  }
}


                ### Instances ###

resource "aws_instance" "vpn_host" {
  instance_type = "t2.micro"
  ami = "${var.ami}"
  key_name = "${var.key}"

  network_interface = {
    network_interface_id = "${aws_network_interface.vpn_host_ni.id}"
    device_index = 0
    delete_on_termination = false
  }
  volume_tags = {
    size = 10
    Name = "vpn_host_volume"
    ita_group = "Lv-378"
    owner = "svyatoslav"
    note = "non_academy_task"
    aim = "aws_study"
  }
  tags ={
      Name = "vpn_host"
      ita_group = "Lv-378"
      owner = "svyatoslav"
      note = "non_academy_task"
      aim = "aws_study"
  }
}

