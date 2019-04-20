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
  availability_zone = "us-east-2a"

  tags = {
    Name = "public_subnet"
    ita_group = "Lv-378"
    owner = "svyatoslav"
  }
}

resource "aws_subnet" "private_subnet" {
  cidr_block = "192.168.2.0/24"
  vpc_id = "${aws_vpc.svyatoslav_vpc.id}"
  map_public_ip_on_launch = false
  availability_zone = "us-east-2a"

  tags = {
    Name = "private_subnet"
    ita_group = "Lv-378"
    owner = "svyatoslav"
  }
}

resource "aws_subnet" "database_subnet" {
  cidr_block = "192.168.3.0/24"
  vpc_id = "${aws_vpc.svyatoslav_vpc.id}"
  map_public_ip_on_launch = true
  availability_zone = "us-east-2b"

  tags = {
    Name = "database_subnet"
    ita_group = "Lv-378"
    owner = "svyatoslav"
  }
}

resource "aws_db_subnet_group" "oms_db_subgroup" {
  name = "oms_db_subgroup"
  description = "Group of public subnets to db"
  subnet_ids = [
    "${aws_subnet.public_subnet.id}",
    "${aws_subnet.database_subnet.id}"
  ]

  tags = {
    Name = "oms_db_subgroup"
    ita_group = "Lv-378"
    owner = "svyatoslav"
  }
}


resource "aws_eip" "jenkins_eip" {
  network_interface = "${aws_network_interface.jenkins_ni.id}"
  vpc = true

  tags ={
      Name = "jenkins_eip"
      ita_group = "Lv-378"
      owner = "svyatoslav"
  }
}


          ### Network elements ###

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

resource "aws_network_interface" "oms_db_ni" {
  subnet_id ="${aws_subnet.public_subnet.id}"
  security_groups = ["${aws_security_group.only_mysql.id}"]
  description = "RDSNetworkInterface"

  tags ={
      Name = "oms_db_ni"
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

resource "aws_security_group" "only_ssh" {
  vpc_id = "${aws_vpc.svyatoslav_vpc.id}"
  description = "only ssh"
  name = "only_ssh"

  ingress = {
    from_port = 22
    to_port = 22
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
    Name = "only_ssh_sg"
    ita_group = "Lv-378"
    owner = "svyatoslav"
  }
}

resource "aws_security_group" "only_mysql" {
  vpc_id = "${aws_vpc.svyatoslav_vpc.id}"
  description = "only mysql"
  name = "only_mysql"

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

  tags = {
    Name = "only_mysql_sg"
    ita_group = "Lv-378"
    owner = "svyatoslav"
  }
}
            ###Instances###


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
  storage_type = "gp2"
  engine = "mariadb"
  engine_version = "10.3.8"
  name = "oms_db"
  username = "svyatoslav"
  password = "password"
  license_model = "general-public-license"
  port = 3306
  publicly_accessible = true
  vpc_security_group_ids = ["${aws_security_group.only_mysql.id}"]
  availability_zone = "us-east-2a"
  db_subnet_group_name = "${aws_db_subnet_group.oms_db_subgroup.name}"
  identifier = "oms-db"
  multi_az = false
  allow_major_version_upgrade = true
  copy_tags_to_snapshot = true
  deletion_protection = true
  skip_final_snapshot = true
  auto_minor_version_upgrade = false


  tags = {
      Name = "oms_db"
      ita_group = "Lv-378"
      owner = "svyatoslav"
  }

  depends_on = [
    "aws_db_subnet_group.oms_db_subgroup"
    ]
}
