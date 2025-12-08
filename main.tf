# This is required to make the configuration portable and always use the current, secure AMI.
data "aws_ami" "latest_amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}
data "cloudinit_config" "example_config" {
    gzip          = false
    base64_encode = false

    part {
    content_type = "text/cloud-config"
    content = yamlencode({
        write_files = [
        {
            path        = "/tmp/playbook.yaml"
            permissions = "0644"
            owner       = "root:root"
            encoding    = "b64"
            content     = filebase64("./playbook.yaml")
        },
        ]
    })
    }
    part {
    filename = "run_playbook.sh"
    content_type = "text/x-shellscript"
    content = <<-EOF
        #!/bin/bash
        yum update -y
        yum yum install -y ansible
        amazon-linux-extras install -y ansible2
        yum install python3 -y
        yum install python3-pip -y
        sleep 10
        cd /tmp/
        ansible-playbook /tmp/playbook.yaml > "/tmp/playbook.log" 2>&1
    EOF
    }
}

resource "aws_security_group" "web_sg" {
  name        = "web_server_sg"
  description = "Allow HTTP and SSH inbound traffic"

  # Inbound Rule: Allow HTTP (Port 80) from anywhere
  ingress {
    description = "HTTP from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
 tags = {
    Name = "Web Security Group"
  }
} 

resource "aws_instance" "web_server" {
  ami           = data.aws_ami.latest_amazon_linux.id
  instance_type = var.instance_type
  user_data     = data.cloudinit_config.example_config.rendered

  # Attach the Security Group
  vpc_security_group_ids = [aws_security_group.web_sg.id]

  tags = {
    Name = "Terraform-Web-Server"
   }
}