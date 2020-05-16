output "instance_public_ip" {
  value = data.aws_instances.techtest_app.public_ips
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
    aws_autoscaling_group.techtest_app
  ]
  vars = {
    ec2_public_ip = element(data.aws_instances.techtest_app.public_ips, 0)
  }
}

data "template_file" "database" {
  template = file("../ansible/templates/database.tpl")
  depends_on = [
    aws_db_instance.techtest_app
  ]
  vars = {
    db_host     = aws_db_instance.techtest_app.address
    db_username = aws_db_instance.techtest_app.username
    db_password = aws_db_instance.techtest_app.password
    db_port     = aws_db_instance.techtest_app.port
    db_name     = aws_db_instance.techtest_app.name
  }
}

resource "null_resource" "inventory" {
  triggers = {
    template_rendered = data.template_file.inventory.rendered
  }
}

resource "null_resource" "database" {
  triggers = {
    template_rendered = data.template_file.database.rendered
  }
}

output "ansible_inventory" {
  value = data.template_file.inventory.rendered
}

output "database_template" {
  value = data.template_file.database.rendered
}

output "s3_bucket_name" {
  value = aws_s3_bucket.terraform-state-storage-s3.bucket
}

output "dynamodb_bucket_name" {
  value = aws_dynamodb_table.dynamodb-terraform-state-lock.name
}