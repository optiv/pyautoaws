# Configure the AWS Provider
provider "aws" {
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
  region     = "${var.aws_region}"
}

resource "aws_security_group" "ec2_access" {
    name = "ec2_access"

    # Inbound rules
    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["${var.ip}/32"] 
    }

    # Outbound rules
    egress {
        from_port        = 0
        to_port          = 0
        protocol         = "-1"
        cidr_blocks      = ["0.0.0.0/0"]     
    }
}

data "aws_ami" "ubuntu" {
    most_recent = true

    filter {
        name   = "name"
        values = ["ubuntu/images/hvm-ssd/ubuntu-*-amd64-server-*"] # recent ubuntu version
    }

    filter {
        name   = "virtualization-type"
        values = ["hvm"]
    }

    owners = ["099720109477"] # Canonical
}

resource "aws_instance" "ec2" {
  ami           = "${data.aws_ami.ubuntu.id}"
  count         = "${var.instance_count}"
  instance_type = "t2.micro"
  associate_public_ip_address = "true"
  key_name = "${var.aws_key_name}"
  vpc_security_group_ids = ["${aws_security_group.ec2_access.id}"]
  root_block_device {
    volume_size = 16
  }
  tags = {
    Name = "${var.name}"
  }

    provisioner "remote-exec" {
    inline = [
      "cloud-init status --wait"
    ]
  }
    # Requires SSH agent configuration
    connection {
    type = "ssh"
    user = "ubuntu"
    timeout = "2m"
    host = self.public_ip
  }
}

resource "local_file" "ec2_hosts" {
  filename = "ec2_hosts"
  file_permission = "0644"
  content = <<-EOT
    %{ for ip in aws_instance.ec2.*.public_ip ~}
    ${ip}
    %{ endfor ~}
  EOT
}


resource "null_resource" "ec2_playbook" {
  depends_on = [
    local_file.ec2_hosts
  ]
  provisioner "local-exec" {
    command = "ANSIBLE_STDOUT_CALLBACK=yaml ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i ec2_hosts ec2-playbook.yml"
  }
}


resource "local_file" "vars" {
  filename = "project_vars.tfvars" 
  file_permission = "0644"
  content = <<-EOT
    aws_region = "${var.aws_region}"
    name = "${var.name}"
    instance_count = "${var.instance_count}"
    ip = "${var.ip}"
  EOT
}
