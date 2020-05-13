output "instance_public_ip" {
  value = aws_instance.techtest_app.public_ip
}

output "lb_endpoint" {
  value = aws_lb.techtest_app.dns_name
}

output "db_endpoint" {
  value = aws_db_instance.techtest_app.endpoint
}

output "db_user" {
  value = aws_db_instance.techtest_app.username
}

output "db_pass" {
  value       = aws_db_instance.techtest_app.password
  description = "Password for logging in to the database"
  sensitive   = true
}

data "template_file" "inventory" {
  template = file("../ansible/templates/inventory.tpl")
  depends_on = [
    aws_instance.techtest_app
  ]
  vars = {
    ec2_public_ip = aws_instance.techtest_app.public_ip
  }
}

resource "null_resource" "inventory" {
  triggers = {
    template_rendered = data.template_file.inventory.rendered
  }
}

output "ansible_inventory" {
  value = data.template_file.inventory.rendered
}