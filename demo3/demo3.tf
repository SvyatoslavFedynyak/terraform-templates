provider "aws" {
  region = "us-east-2"
}

          ###Networking###

resource "aws_vpc" "svyatoslav_vpc" {
  cidr_block = "192.168.0.0/16"

  tags = {
      Name = "svyatoslav_vpc"
      ita_group = "Lv-378"
      owner = "svyatoslav"
  }
}

resource "aws_subnet" "public_subnet" {
  cidr_block = "192.168.1.0/24"
  vpc_id = "${aws_vpc.svyatoslav_vpc.id}"
  map_public_ip_on_launch = true

  tags = {
    Name = "public_subnet"
    ita_group = "Lv-378"
    owner = "svyatoslav"
  }
}

resource "aws_network_interface" "bastion_ni" {
  subnet_id ="${aws_subnet.public_subnet.id}"
  security_groups = ["${aws_security_group.basic_web_sg.id}"]

  tags ={
      Name = "bastion_ni"
      ita_group = "Lv-378"
      owner = "svyatoslav"
  }

  attachment = {
  instance = "${aws_instance.bastion.id}"
  device_index = 1
  }
}

resource "aws_security_group" "basic_web_sg" {
  vpc_id = "${aws_vpc.svyatoslav_vpc.id}"
  description = "ssh"

  ingress = {
  from_port = 22
  to_port = 22
  protocol = "-1"
  cidr_blocks = ["0.0.0.0/0"]
  }

  ingress = {
  from_port = 80
  to_port = 80
  protocol = "-1"
  cidr_blocks = ["0.0.0.0/0"]
  }

  ingress = {
  from_port = 443
  to_port = 443
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  }

  ingress = {
  from_port = 80
  to_port = 80
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
    Name = "basic_web_sg"
    ita_group = "Lv-378"
    owner = "svyatoslav"
  }
}


            ###Instances###

resource "aws_instance" "bastion" {
  instance_type = "t2.micro"
  ami = "ami-02bcbb802e03574ba"
  
  availability_zone = "us-east-2a"
  key_name = "svyatoslav_key"


  volume_tags = {
    size = 10
    Name = "bastion_volume"
    ita_group = "Lv-378"
    owner = "svyatoslav"
  }
  tags ={
      Name = "bastion"
      ita_group = "Lv-378"
      owner = "svyatoslav"
  }
}

resource "aws_instance" "jenkins-server" {
  instance_type = "t2.micro"
  ami = "ami-02bcbb802e03574ba"

  subnet_id = "subnet-0bb6ee3a12f42b5bb"

  disable_api_termination = "true"

  tags = {
      Name = "jenkins-server"
      ita_group = "Lv-378"
      owner = "svyatoslav"
  }
}

            ###Volumes###

/*resource "aws_ebs_volume" "bastion_volume" {
  availability_zone = "us-east-2a"
  size = 10
  tags = {
    Name = "bastion-volume"
    ita_group = "Lv-378"
    owner = "svyatoslav"
  }
}*/
