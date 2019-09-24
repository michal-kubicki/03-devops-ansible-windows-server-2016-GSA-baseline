provider "aws" {
  profile = "default"
  region = "eu-west-2"
}

#Find the Windows_Server-2016-English-Full-Base AMI in your current region
data "aws_ami" "windows_server_2016_base" {
  most_recent = true
  filter {
    name   = "name"
    values = ["Windows_Server-2016-English-Full-Base-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["801119661308"]
}

#Adopt the default VPC
resource "aws_default_vpc" "default" {}

#Adopt the default security group in the default VPC
resource "aws_default_security_group" "winrt-rdp" {
  vpc_id = "${aws_default_vpc.default.id}"
}

#Ensure the Internet access is enabled
resource "aws_security_group_rule" "egress"{
  security_group_id = aws_default_security_group.winrt-rdp.id
    type = "egress"
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

#Open the RDP port
resource "aws_security_group_rule" "rdp"{
  security_group_id = aws_default_security_group.winrt-rdp.id
  type = "ingress"
  from_port = 3389
  to_port = 3389
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
}

#Open the WinRM port for Ansible
resource "aws_security_group_rule" "winrm"{
  security_group_id = aws_default_security_group.winrt-rdp.id
  type = "ingress"
  from_port = 5986
  to_port = 5986
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
}

#Create a t2.micro instance running Windows Server 2016
resource "aws_instance" "windows_server_2016" {
  ami = data.aws_ami.windows_server_2016_base.id
  instance_type = "t2.micro"
  monitoring = false
  vpc_security_group_ids = [aws_default_security_group.winrt-rdp.id]
  user_data = file("enable_ansible.ps1")
}

#Output the public IP
output "public_ip" {
  description = "List of public IP addresses assigned to the instances, if applicable"
  value = aws_instance.windows_server_2016.public_ip
}