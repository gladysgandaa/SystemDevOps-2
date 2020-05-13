provider "aws" {
  version = "~> 2.23"
  region  = "us-east-1"
}

resource "aws_security_group" "allow_http_ssh" {
  description = "Allow SSH and http inbound traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "ssh from internet"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "http from internet"
    from_port   = 80
    to_port     = 80
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
    Name = "allow_http_ssh"
  }
}

# data "template_file" "web_ansible" { 
#     count = length(split(",",var.web_ips))
#     template = file("../ansible/templates/hostname.tpl")
#     vars = {
#         index = "count.index + 1"
#         name  = "web"
#         env   = "p"
#         # extra = "ansible_host = element(split(",",var.web_ips),count.index)"
#         # extra = ""
#     }
# }

# resource "template_file" "ansible_inventory" {
#     template = file("../ansible/templates/inventory.tpl")
#     vars = {
#         env         = "production"
#         web_hosts   =  join("\n", template_file.web_ansible.*.rendered)
#     }
# }
