# provider "aws" {
#   region = "ap-south-1"
# }

# resource "aws_vpc" "myapp-vpc" {
#   cidr_block = var.vpc_cidr_block
#   tags = {
#     Name = "${var.env_prefix}-vpc"
#   }
# }

# module "myapp-subnet"{
#   source = "./modules/subnet"
#   // now the values of those variablers need to be provided when we are refering to that module . 
#   // previously we were passing those variables from the terraform.tfvars files . 
#   subnet_cidr_block = var.subnet_cidr_block //set as value in variable.tf file in root. 
#   // values are passed to child modulees as argument also via variables.tf in child modulel subnet ->variable.tf
#   avail_zone = var.avail_zone // also in root tfvars file .
#   env_prefix = var.env_prefix // also in root tfvars file. 
#    vpc_id  = aws_vpc.myapp-vpc.id// also in root tfvars file value defined all of these varaibel in tfvars file . 
#    default_route_table_id = aws_vpc.myapp-vpc.default_route_table_id

# }

# // now reference that webserver module in here . 
# module "myapp-server"{
#     source = "./modules/webserver"
#   vpc_id = aws_vpc.myapp-vpc.id
#   my_ip  = var.my_ip
#   env_prefix = var.env_prefix
#   image_name = var.image_name
#   my_public_key_location = var.my_public_key_location
#   instance_type = var.instance_type
#   subnet_id = module.myapp-subnet.subnet.id
#   avail_zone = var.avail_zone
# }



provider "aws" {
    region = "eu-west-3"
}

resource "aws_vpc" "myapp-vpc" {
    cidr_block = var.vpc_cidr_block
    tags = {
        Name = "${var.env_prefix}-vpc"
    }
}

module "myapp-subnet" {
    source = "./modules/subnet"
    subnet_cidr_block = var.subnet_cidr_block
    avail_zone = var.avail_zone
    env_prefix = var.env_prefix
    vpc_id = aws_vpc.myapp-vpc.id
    default_route_table_id = aws_vpc.myapp-vpc.default_route_table_id
}

module "myapp-server" {
    source = "./modules/webserver"
    vpc_id = aws_vpc.myapp-vpc.id
    my_ip = var.my_ip
    env_prefix = var.env_prefix
    image_name = var.image_name
    public_key_location = var.public_key_location
    instance_type = var.instance_type
    subnet_id = module.myapp-subnet.subnet.id
    avail_zone = var.avail_zone
}
