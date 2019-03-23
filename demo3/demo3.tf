provider "aws" {
  region = "us-east-2"
}

          ### Vpc and subnets ###

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

resource "aws_subnet" "private_subnet" {
  cidr_block = "192.168.2.0/24"
  vpc_id = "${aws_vpc.svyatoslav_vpc.id}"
  map_public_ip_on_launch = true

  tags = {
    Name = "private_subnet"
    ita_group = "Lv-378"
    owner = "svyatoslav"
  }
}

resource "aws_subnet" "database1_subnet" {
  cidr_block = "192.168.3.0/24"
  vpc_id = "${aws_vpc.svyatoslav_vpc.id}"
  map_public_ip_on_launch = true

  tags = {
    Name = "database1_subnet"
    ita_group = "Lv-378"
    owner = "svyatoslav"
  }
}

resource "aws_subnet" "database2_subnet" {
  cidr_block = "192.168.4.0/24"
  vpc_id = "${aws_vpc.svyatoslav_vpc.id}"
  map_public_ip_on_launch = true

  tags = {
    Name = "database2_subnet"
    ita_group = "Lv-378"
    owner = "svyatoslav"
  }
}


          ### Network elements ###
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

resource "aws_network_interface" "jenkins_ni" {
  subnet_id ="${aws_subnet.public_subnet.id}"
  security_groups = ["${aws_security_group.basic_web_sg.id}"]
    description = "Jenkins Network Interface"

  tags ={
      Name = "jenkins_ni"
      ita_group = "Lv-378"
      owner = "svyatoslav"
  }
}

resource "aws_network_interface" "rds_ni" {
  subnet_id ="${aws_subnet.database1_subnet.id}"
  security_groups = ["${aws_security_group.basic_web_sg.id}"]
  description = "RDSNetworkInterface"

  tags ={
      Name = "rds_ni"
      ita_group = "Lv-378"
      owner = "svyatoslav"
  }

  lifecycle = {
    ignore_changes = true
  }
}

            ### Security groups ###
resource "aws_security_group" "basic_web_sg" {
  vpc_id = "${aws_vpc.svyatoslav_vpc.id}"
  description = "ssh"
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

resource "aws_security_group" "all_traphic_sg" {
  vpc_id = "${aws_vpc.svyatoslav_vpc.id}"
  description = "all"

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
  }
}


            ###Instances###

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

            ### S3 ###

resource "aws_s3_bucket" "war_bucket" {
  bucket = "svyatoslav-bucket-for-oms.war"
  acl = "public-read"
  force_destroy = false

  tags = {
      Name = "svyatoslav-bucket-for-oms.war"
      ita_group = "Lv-378"
      owner = "svyatoslav"
  }
}

          ### Pipeline ###

resource "aws_codebuild_project" "build_oms_image" {
  name = "oms-image-build"
  description = "Rebuilds OMS Docker image"
  service_role = "arn:aws:iam::536460581283:role/code-build-role"

  environment = {
    compute_type = "BUILD_GENERAL1_SMALL"
    image = "aws/codebuild/docker:18.09.0"
    type = "LINUX_CONTAINER"
    privileged_mode = true
  }

  lifecycle = {
    ignore_changes = [
      "source"
    ]
  }

  source = {
    type = "S3"
    location = "${aws_s3_bucket.war_bucket.bucket}/war/"
  }

  artifacts = {
    type = "NO_ARTIFACTS"
  }

  tags = {
      Name = "oms-image-build"
      ita_group = "Lv-378"
      owner = "svyatoslav"
  }
}

resource "aws_ecr_repository" "tomcat-oms" {
  name = "tomcat-oms"

  tags = {
      Name = "tomcat-oms"
      ita_group = "Lv-378"
      owner = "svyatoslav"
  }
}

resource "aws_ecs_cluster" "svyatoslav-cluster" {
  name = "svyatoslav-cluster"

  tags = {
      Name = "svyatoslav-cluster"
      ita_group = "Lv-378"
      owner = "svyatoslav"
  }
}

resource "aws_ecs_service" "tomcat-oms-ecs-service" {
  name = "tomcat-oms-container"
  cluster = "${aws_ecs_cluster.svyatoslav-cluster.id}"
  task_definition = "${aws_ecs_task_definition.tomcat-oms-server.id}"
  desired_count = 1
  launch_type = "FARGATE"
  network_configuration = {
    subnets = ["${aws_subnet.public_subnet.id}"]
    security_groups = ["${aws_security_group.basic_web_sg.id}"]
    assign_public_ip = true
  }

  tags = {
      Name = "tomcat-oms-ecs-service"
      ita_group = "Lv-378"
      owner = "svyatoslav"
  }

  depends_on = ["aws_ecs_task_definition.tomcat-oms-server"]
}

resource "aws_ecs_task_definition" "tomcat-oms-server" {
  family = "Tomcat-OMS-Server"
  container_definitions = "${file("data/task-definitions/service.json")}"
  network_mode = "awsvpc"
  cpu = 256
  memory = 512
  requires_compatibilities = ["FARGATE"]
  task_role_arn = "arn:aws:iam::536460581283:role/ecsTaskExecutionRole"
  execution_role_arn = "arn:aws:iam::536460581283:role/ecsTaskExecutionRole"

  tags = {
      Name = "tomcat-oms-server"
      ita_group = "Lv-378"
      owner = "svyatoslav"
  }
}



          ### RDS ###

resource "aws_db_instance" "oms_db" {
  allocated_storage = 20
  instance_class = "db.t2.micro"
  skip_final_snapshot = true
  copy_tags_to_snapshot = true
  auto_minor_version_upgrade = false
  tags = {
      Name = "oms_db"
      ita_group = "Lv-378"
      owner = "svyatoslav"
      workload-type = "other"
  }

  lifecycle = {
    ignore_changes = [
       "deletion_protection",
      "enabled_cloudwatch_logs_exports"
    ]
  }
}
