# output "instance_public_ip" {
#   value = 
# }

output "lb_endpoint" {
  value = aws_lb.techtest_app.dns_name
}

# output "db_endpoint" {
#   value = 
# }

# output "db_user" {
#   value = 
# }

# output "db_pass" {
#   value = 
# }