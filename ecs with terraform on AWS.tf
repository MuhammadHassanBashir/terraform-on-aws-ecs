#####################################################################
# Block-1: Terraform Settings Block
terraform {
  required_version = "~> 1.4"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0"
    }
  }
##Adding Backend as S3 for Remote State Storage with State Locking
#  backend "s3" 
# {
#   bucket = "terraform-stacksimplify"
#   key    = "dev2/terraform.tfstate"
#   region = "us-east-1"  

#    # For State Locking
#   dynamodb_table = "terraform-dev-state-table"
# } 
}
#####################################################################
# Block-2: Provider Block
provider "aws" {
  profile = "default" # AWS Credentials Profile configured on your local desktop terminal  $HOME/.aws/credentials
  region  = "us-east-1"
}
#####################################################################
# Block-3: Resource Block
resource "aws_vpc" "main" {
 cidr_block           = var.vpc_cidr
 enable_dns_hostnames = true
 tags = {
   name = "main"
 }
}
################################## SUBNETS ###################################
resource "aws_subnet" "subnet" {
 vpc_id                  = aws_vpc.main.id
 cidr_block              = cidrsubnet(aws_vpc.main.cidr_block, 8, 1)
 map_public_ip_on_launch = true
 availability_zone       = "us-east-1a"
}

resource "aws_subnet" "subnet2" {
 vpc_id                  = aws_vpc.main.id
 cidr_block              = cidrsubnet(aws_vpc.main.cidr_block, 8, 2)
 map_public_ip_on_launch = true
 availability_zone       = "us-east-1b"
}

################################## Internet-Gateway ##################################
resource "aws_internet_gateway" "internet_gateway" {
 vpc_id = aws_vpc.main.id
 tags = {
   Name = "internet_gateway"
 }
}

################################## Route-Table ##################################
resource "aws_route_table" "route_table" {
 vpc_id = aws_vpc.main.id
 route {
   cidr_block = "0.0.0.0/0"
   gateway_id = aws_internet_gateway.internet_gateway.id
 }
}

################################## Route-Association ################################
resource "aws_route_table_association" "subnet_route" {
 subnet_id      = aws_subnet.subnet.id
 route_table_id = aws_route_table.route_table.id
}

resource "aws_route_table_association" "subnet2_route" {
 subnet_id      = aws_subnet.subnet2.id
 route_table_id = aws_route_table.route_table.id
}

################################## Security-Group ################################
resource "aws_security_group" "security_group" {
 name   = "ecs-security-group"
 vpc_id = aws_vpc.main.id

 ingress {
   from_port   = 0
   to_port     = 0
   protocol    = -1
   self        = "false"
   cidr_blocks = ["0.0.0.0/0"]
   description = "any"
 }

 egress {
   from_port   = 0
   to_port     = 0
   protocol    = "-1"
   cidr_blocks = ["0.0.0.0/0"]
 }
}


