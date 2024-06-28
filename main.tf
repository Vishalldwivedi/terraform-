provider "aws" {
  region     = "ap-south-1"
 
}

variable "cidr-blocks" {
  description = "cidr blocks and name tags for vpcs and subnets"
  type        = list(object({
    cidr_block = string
    name = string
  }))
}

variable "environment" {
  description = "deployment environment"
}
variable avail_zone{}

resource "aws_vpc" "development-vpc" {
  cidr_block = var.cidr-blocks[0].cidr_block
  tags = {
    Name = var.cidr-blocks[0].name
  }
}

resource "aws_subnet" "dev-subnet-1" {
  vpc_id            = aws_vpc.development-vpc.id
  cidr_block        = var.cidr-blocks[1].cidr_block
  availability_zone = var.avail_zone
  tags = {
    Name = var.cidr-blocks[1].name
  }
}
output "dev-vpc-id" {
  value = aws_vpc.development-vpc.id
}

output "dev-subnet-id" {
  value = aws_subnet.dev-subnet-1.id
}