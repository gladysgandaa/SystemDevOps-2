# resource "aws_key_pair" "deployer" {
#   key_name   = "deployer-key"
#   public_key = var.public_key
# }

# # resource "aws_instance" "techtestapp_instance" {
# #   ami           = "ami-0323c3dd2da7fb37d"
# #   instance_type = "t2.micro"
# #   #   subnet_id            = ["aws_subnet.private_az1.id","aws_subnet.private_az2.id","aws_subnet.private_az3.id"]

# #   tags = {
# #     Name = "TechTestApp_Instance"
# #   }
# # }

