provider "aws" {
  region = "us-east-1"
}

locals {
  name   = "ug-dev-118"
  region = "us-east-1"
  
  user_data = <<-EOT
  #!/bin/bash
  echo "bastion host"
  EOT

    user_data_app = <<-EOT
  #!/bin/bash
  echo "app host"
  EOT

    user_data_jenkins = <<-EOT
  #!/bin/bash
  echo "jenkins host"
  EOT

  tags = {
    Owner       = "rohit"
    Environment = "dev"
    projectid   = "118"
  }
}




################################################################################
# VPC Module
################################################################################

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = local.name
  cidr = "20.10.0.0/16"

  azs                 = ["${local.region}a", "${local.region}b"]
  private_subnets     = ["20.10.1.0/24", "20.10.2.0/24"]
  public_subnets      = ["20.10.11.0/24", "20.10.12.0/24"]
  
  enable_nat_gateway = true
  single_nat_gateway = true
		}


### bastion ###

module "bastionsg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 4.0"

  name        = "bastsg"
  description = "Security group for bastion instance"
  vpc_id      = module.vpc.vpc_id

  ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_rules       = ["ssh-tcp", "all-icmp"]
  egress_rules        = ["all-all"]

  tags = local.tags
}
### module for bastion ec2 ###

module "ec2_bastion" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 3.0"
  
  name = "bastion"

  ami                         = "ami-083654bd07b5da81d"
  instance_type               = "t3.micro"
  availability_zone           = element(module.vpc.azs, 0)
  subnet_id                   = element(module.vpc.public_subnets, 0)
  vpc_security_group_ids      = [module.bastionsg.security_group_id]
  key_name                    = "dev"
  associate_public_ip_address = true

  user_data_base64 = base64encode(local.user_data)

  enable_volume_tags = false
  root_block_device = [
    {
      encrypted   = true
      volume_type = "gp3"
      throughput  = 200
      volume_size = 20
      tags = {
        Name = "my-root-block"
      }
    }
  ]

  tags = local.tags
}


### app ###

module "app_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 4.0"

  name        = "appsg"
  description = "Security group for app instance"
  vpc_id      = module.vpc.vpc_id

  ingress_cidr_blocks = ["20.10.0.0/16"]
  ingress_rules       = ["all-all"]
  computed_ingress_with_source_security_group_id = [
    {
      rule                     = "http-8080-tcp"
      source_security_group_id = module.alb_sg.security_group_id
    },
    {
      rule                     = "ssh-tcp"
      source_security_group_id = module.bastionsg.security_group_id
    },    
  ]

  number_of_computed_ingress_with_source_security_group_id = 2
  egress_rules        = ["all-all"]
  tags = local.tags
}
### module for app ec2 ###

module "ec2_app" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 3.0"
  
  name = "app"

  ami                         = "ami-083654bd07b5da81d"
  instance_type               = "t3.micro"
  availability_zone           = element(module.vpc.azs, 0)
  subnet_id                   = element(module.vpc.private_subnets, 0)
  vpc_security_group_ids      = [module.app_sg.security_group_id]
  key_name                    = "dev"
  associate_public_ip_address = false

  user_data_base64 = base64encode(local.user_data_app)

  enable_volume_tags = false
  root_block_device = [
    {
      encrypted   = true
      volume_type = "gp3"
      throughput  = 200
      volume_size = 30
      tags = {
        Name = "my-root-block"
      }
    }
  ]

  tags = local.tags
}
		
### jenkins ###

module "jenkins_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 4.0"

  name        = "jenkins_sg"
  description = "Security group for jenkins instance"
  vpc_id      = module.vpc.vpc_id

  ingress_cidr_blocks = ["20.10.0.0/16"]
  ingress_rules       = ["all-all"]
  computed_ingress_with_source_security_group_id = [
    {
      rule                     = "http-8080-tcp"
      source_security_group_id = module.alb_sg.security_group_id
    },
    {
      rule                     = "ssh-tcp"
      source_security_group_id = module.bastionsg.security_group_id
    },    
  ]

  number_of_computed_ingress_with_source_security_group_id = 2  
  egress_rules        = ["all-all"]

  tags = local.tags
}
### module for jenkins ec2 ###

module "ec2_jenkins" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 3.0"
  
  name = "jenkins"

  ami                         = "ami-083654bd07b5da81d"
  instance_type               = "t3.micro"
  availability_zone           = element(module.vpc.azs, 0)
  subnet_id                   = element(module.vpc.private_subnets, 0)
  vpc_security_group_ids      = [module.jenkins_sg.security_group_id]
  key_name                    = "dev"
  associate_public_ip_address = false

  user_data_base64 = base64encode(local.user_data_jenkins)

  enable_volume_tags = false
  root_block_device = [
    {
      encrypted   = true
      volume_type = "gp3"
      throughput  = 200
      volume_size = 30
      tags = {
        Name = "my-root-block"
      }
    }
  ]

  tags = local.tags
}

###ALB SG ###
module "alb_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 4.0"

  name        = "albsg"
  description = "Security group for alb"
  vpc_id      = module.vpc.vpc_id

  ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_rules       = ["http-80-tcp"]
  egress_rules        = ["all-all"]
  tags = local.tags
}

### ALB ###
module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "~> 6.0"

  name = "my-alb"

  load_balancer_type = "application"

  vpc_id             = module.vpc.vpc_id
  subnets            = module.vpc.public_subnets
  security_groups    = [module.alb_sg.security_group_id]


  target_groups = [
    {
      name      = "jenkins-tg"
      backend_protocol = "HTTP"
      backend_port     = 80
      target_type      = "instance"
      targets = [
        {
          target_id = module.ec2_jenkins.id
          port = 8080
        }
      ]
    },
     {
      name      = "app-tg"
      backend_protocol = "HTTP"
      backend_port     = 80
      target_type      = "instance"
      targets = [
        {
          target_id = module.ec2_app.id
          port = 8080
        }
      ]
    }   
  ]

  http_tcp_listeners= [
    {
      port               = 80
      protocol           = "HTTP"
      target_group_index = 0
    }

  ]

  tags = {
    Environment = "dev"
  }
}

