provider "aws" {
  region = "us-east-2"
}

resource "aws_network_interface" "bastion_ni" {
  subnet_id ="${aws_subnet.public_subnet.id}"
  security_groups = ["${aws_security_group.basic_web_sg.id}"]
  description = "Bastion Network Interface"

  tags ={
      Name = "bastion_ni"
      ita_group = "Lv-378"
      owner = "svyatoslav"
  }
}

resource "aws_eip" "bastion_eip" {
  vpc = true
  network_interface = "${aws_network_interface.bastion_ni.id}"

  tags ={
      Name = "bastion_eip"
      ita_group = "Lv-378"
      owner = "svyatoslav"
  }
}

resource "aws_instance" "bastion" {
  instance_type = "t2.micro"
  ami = "ami-02bcbb802e03574ba"
  
  network_interface = {
    network_interface_id = "${aws_network_interface.bastion_ni.id}"
    device_index = 0
    delete_on_termination = false
  }
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
