provider "aws" {
  region = "${var.region}"
}

resource "aws_eip" "main_eip" {
  instance = "${aws_instance.terraform-study-instance.id}"
}

resource "aws_instance" "terraform-study-instance" {
            ###Main###
  ami = "ami-02bcbb802e03574ba"
  instance_type = "t2.micro"

    ###Network, security, connection###
  availability_zone = "us-east-2a"
  subnet_id = "subnet-0bb6ee3a12f42b5bb"
  vpc_security_group_ids = ["sg-0e8861348f923290c"]
  key_name = "svyatoslav_key"

            ###Tags###
  tags = {
      ita_group = "Lv-378"
      Name = "terraform_study_instance"
      feature = "terraform"
  }
  volume_tags = {
      ita_group = "Lv-378"
      feature = "terraform"
  }
}
