# Servian TechTestApp

## Generating VPC
- Generate 9 subnets in 3 layers accross 3 availability zone. we are generating 3 subnets each on the public, private and data layer.By doing that, we can then specify our instance, load balancer and database to the desired layer.


## Create 3 Layer Application Infrastructure

- We are assigning the load balancer specifically deployed to the Public Layer by specifying subnets to the public layer we have created earlier. Load balancer target group are also generated in order to route request to one or more reigstered target, and lastly the load balancer listener to check for connection request.

``` Load Balancer
resource "aws_lb" "techtest_app" {
  name               = "techtest-app-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.allow_http_ssh.id]
  subnets            = [aws_subnet.public_az1.id, aws_subnet.public_az2.id, aws_subnet.public_az3.id]

  tags = {
    Environment = "production"
  }
}
```

- EC2 instance are generated and applied to the private layer. There are 3 private subnets that has been assigned to vpc_zone_identifier, and for the output of the public ip address, so in this case, I am using the first address from the subnets array. We are then going to deploy the application to the instance.

``` EC2
resource "aws_autoscaling_group" "techtest_app" {
  name                 = "terraform-asg-example"
  launch_configuration = aws_launch_configuration.techtest_app.name
  min_size             = 1
  max_size             = 1
  vpc_zone_identifier  = [aws_subnet.private_az1.id, aws_subnet.private_az2.id, aws_subnet.private_az3.id]
  target_group_arns    = [aws_lb_target_group.techtest_app.arn]
  tag {
    key                 = "key"
    value               = "instance-deploy"
    propagate_at_launch = true
  }
}
```

- In this case, database are being deployed to the data layer. aws_db_subnet_group is created and later on specified on aws_db_instance. Database is mandatory for running the application and has to be specified correctly in order for the application to run.

``` Database
resource "aws_db_subnet_group" "db-subnet" {
  name        = "db-subnet"
  description = "RDS subnet group"
  subnet_ids  = [aws_subnet.data_az1.id, aws_subnet.data_az2.id, aws_subnet.data_az3.id]
}
```


- In the security group, we are creating 4 ingress for port 22, 80, 443, 5432 and 2 egress for port 443 and 5432. Ingress is a traffic that enters the network where egress is the other way around. Port 22 is used to ssh from the interenet, port 443 for https from internet, port 80 used for http, and port 5432 specified for the ec2 database.



## Automate Deployment

- Firstly, we will generate an inventory.yml file. We started by creating a template for the inventory file, containing the public ip of the instance, and the reason of doing this is because the address is a dynamic ip and not a static public address. The data block we are specifying in the outputs.tf read from a given source (such as inventory.tpl) and export the result to inventory.yml file as how he have specified on the run_ansible.sh. Inventory file will be generated when "./run_ansible.sh" is executed.

``` Inventory.yml 
all:
  hosts:
    ${ec2_public_ip}
```
```
terraform output ansible_inventory > ../ansible/inventory.yml
```


- Next, we are going to get the application and extract it to the destination folder. In here, i am extracting it to /etc/app directory, and the application will now be accessible from "/etc/app/dist/" folder. 

```
- name: Unarchive application
    unarchive:
    src: https://github.com/servian/TechTestApp/releases/download/v.0.6.0/TechTestApp_v.0.6.0_linux64.zip
    dest: /etc/app
    remote_src: yes
```


- Thirdly, we have to properly configure the database endpoint in order for us to update the database with seed data, and also to run the application. From the security group that we have specified earlier, i have specified ingress and engress for my port 5432 in order for my database to receive connection, and also specifying my listen port to 0.0.0.0 so it will allow access of all the ip address on the local machine. I have also created a template for the database configuration for it to fetch various data, such as the database name, password and host straight from the terraform output instead of inserting it manually. The data from 'database.yml' will then be stored in 'database_rendered.yml' and uploaded to the playbook to replace the existing conf.toml with the right credentials.

database.tpl
```"DbUser" = "${db_username}"
"DbPassword" = "${db_password}"
"DbName" = "${db_name}"
"DbPort" = "${db_port}"
"DbHost" = "${db_host}"
"ListenHost" = "0.0.0.0"
"ListenPort" = "80"
```
run_ansible.sh
```
terraform output database_template > ../ansible/templates/database_rendered.tpl
```
database_rendered.tpl
```
"DbUser" = "postgres"
"DbPassword" = "rmit1234"
"DbName" = "app"
"DbPort" = "5432"
"DbHost" = "postgres.cwm1gxktw42b.us-east-1.rds.amazonaws.com"
"ListenHost" = "0.0.0.0"
"ListenPort" = "80"
```
playbook.yml
```
- name: Update Database endpoint
    template:
    src: ./templates/database_rendered.tpl
    dest: /etc/app/dist/conf.toml
```


- Lastly, we are setting systemd in order for the application to be automatically start when the server is restarted. Here we have created a unit file which will be used to start the server. On playbook.yaml, state: started will not run any commands unless necessary, and daemon_reload will help make sure systemd has check for changes before running other operations. 

test.tpl
```
[Unit]
Description=TechTestApp Server 

[Service]
Type=simple
User=root
WorkingDirectory=/etc/app/dist
ExecStart=/etc/app/dist/TechTestApp serve
Restart=on-failure

[Install]
WantedBy=multi-user.target 
```
playbook.yml
```
- name: create service 
template:
src: ./templates/test.tpl
dest: /etc/systemd/system/test.service
```

## Automate Database Deployment

- On playbook.yaml, we created another task for seeding the database with some data. We started by changing the directory to the application directory, and then run "./TechTestApp updatedb -s" to update the database with data.

```    
- name: seed data to database
shell: |
cd /etc/app/dist
./TechTestApp updatedb -s
```


## Remote Backend

- In this project, we are setting up S3 and DynamoDB as our remote backend. In main.tf, I have created a command to create a S3 bucket and also DynamoDB table and also setting our initial backend to S3. Run "terraform init" in order to initialize the backend remote.

```
resource "aws_s3_bucket" "terraform-state-storage-s3" {
  bucket = "s3679389-bucket"

   versioning {
     enabled = true
   }

   lifecycle {
     prevent_destroy = true
   }

  tags = {
    Name = "s3 Remote Terraform State"
  }
}
```

Configure S3 back end
```
terraform {
  backend "s3" {
    encrypt        = true
    bucket         = "s3679389-bucket"
    key            = "terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "techtestapp-dynamodb-table"
  }
}
```

```
resource "aws_dynamodb_table" "dynamodb-terraform-state-lock" {
  name           = "techtestapp-dynamodb-table"
  hash_key       = "LockID"
  read_capacity  = 20
  write_capacity = 20

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name = "DynamoDB Terraform State Lock Table"
  }
}
```

## dependencies



## deploy instructions

- Change your directory to infra by doing "cd infra"
- Run terraform apply --auto-approve
- cd to ansible directory by doing "../cd ansible"
- Run "./run_ansible.sh" to generate an inventory.yml folder and run the server
- Using the generated public address, run it on your local web browser and the application should be ready 


## cleanup instructions

- Change your directory to infra by doing "cd infra"
- Run terraform destroy or terraform destroy --auto-approve
