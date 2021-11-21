## vpc ##

output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.vpc.vpc_id
}

## Subnets ##

output "private_subnets" {
  description = "List of IDs of private subnets"
  value       = module.vpc.private_subnets
}

output "public_subnets" {
  description = "List of IDs of public subnets"
  value       = module.vpc.public_subnets
}

## NAT gateways ##

output "nat_public_ips" {
  description = "List of public Elastic IPs created for AWS NAT Gateway"
  value       = module.vpc.nat_public_ips
}


## bastion sg ##


output "bastion_sg__id" {
  description = "The ID of the security group"
  value       = module.bastionsg.security_group_id
}

output "bastion_sg_name" {
  description = "The name of the security group"
  value       = module.bastionsg.security_group_name
}


### bastion ec2 ###

output "ec2_bastion_id" {
  description = "The ID of the instance"
  value       = module.ec2_bastion.id
}

output "ec2_bastion_public_ip" {
  description = "The public IP address assigned to the instance, if applicable. NOTE: If you are using an aws_eip with your instance, you should refer to the EIP's address directly and not use `public_ip` as this field will change after the EIP is attached"
  value       = module.ec2_bastion.public_ip
}

## app sg ##


output "app_sg_id" {
  description = "The ID of the security group"
  value       = module.app_sg.security_group_id
}

output "app_sg_name" {
  description = "The name of the security group"
  value       = module.app_sg.security_group_name
}


### app ec2 ###

output "ec2_app_id" {
  description = "The ID of the instance"
  value       = module.ec2_app.id
}

output "ec2_app_private_ip" {
  description = "The private IP address assigned to the instance"
  value       = module.ec2_app.private_ip
}


## jenkins sg ##


output "jenkins_sg_id" {
  description = "The ID of the security group"
  value       = module.jenkins_sg.security_group_id
}

output "jenkins_sg_name" {
  description = "The name of the security group"
  value       = module.jenkins_sg.security_group_name
}


### jenkins ec2 ###

output "ec2_jenkins_id" {
  description = "The ID of the instance"
  value       = module.ec2_jenkins.id
}

output "ec2_jenkins_private_ip" {
  description = "The public IP address assigned to the instance, if applicable. NOTE: If you are using an aws_eip with your instance, you should refer to the EIP's address directly and not use `public_ip` as this field will change after the EIP is attached"
  value       = module.ec2_jenkins.private_ip
}


## alb sg ##


output "alb_sg_id" {
  description = "The ID of the security group"
  value       = module.alb_sg.security_group_id
}

output "alb_sg_name" {
  description = "The name of the security group"
  value       = module.alb_sg.security_group_name
}

#tg ##

output "target_group_names" {
  description = "Name of the target group. Useful for passing to your CodeDeploy Deployment Group."
  value       = module.alb.target_group_names
}

output "lb_id" {
  description = "The ID and ARN of the load balancer we created."
  value       = module.alb.lb_id
}


