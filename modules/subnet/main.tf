# resource "aws_subnet" "myapp-subnet-1" {
#   vpc_id            = var.vpc_id //aws_vpc.myapp-vpc.id // values should be pass in by who is referencing it .
#   cidr_block        = var.subnet_cidr_block
#   availability_zone = var.avail_zone
#   tags = {
#     Name = "${var.env_prefix}-subent-1"
#   }
# }

# // create  new route table not use the default one
# /*resource "aws_route_table" "myapp-route-table"{
#   vpc_id = aws_vpc.myapp-vpc.id // which vpc this RT belongs to 
#   route {
#     cidr_block = "0.0.0.0/0"// all all ip addresses
#     gateway_id = aws_internet_gateway.myapp-IgateWay.id
#     // here we are referencing intenet gateway here in our route table
#    } 
#    tags = {// naming our resouces for better understand of whole does this belong
#       Name : "${var.env_prefix}-rtb"
#     }
# }
# */

# //creating resource intenet gateway 
# resource "aws_internet_gateway" "myapp-IgateWay"{
#  vpc_id = var.vpc_id // aws_vpc.myapp-vpc.id 
#  tags = {// naming our resouces for better understand of whole does this belong
#       Name : "${var.env_prefix}-igw"
#     }
# }
# /* // explicit subnet assocation with our route table 
# resource "aws_route_table_association" "a-rtb-subnet"{
#   subnet_id = aws_subnet.myapp-subnet-1.id
#   route_table_id = aws_route_table.myapp-route-table.id
# }
# */
# resource "aws_default_route_table" "main_rtb"{
#   default_route_table_id = var.default_route_table_id// get through vpcid 
#   route {
#     cidr_block = "0.0.0.0/0"// all all ip addresses
#     gateway_id = aws_internet_gateway.myapp-IgateWay.id
#     // here we are referencing intenet gateway here in our route table of the same module so we dont need to 
#     // replace it with a variable . 
#    } 
#    tags = {// naming our resouces for better understand of whole does this belong
#       Name : "${var.env_prefix}-main-rtb"
#     }
# }

resource "aws_subnet" "myapp-subnet-1" {
    vpc_id = var.vpc_id
    cidr_block = var.subnet_cidr_block
    availability_zone = var.avail_zone
    tags = {
        Name = "${var.env_prefix}-subnet-1"
    }
}

resource "aws_internet_gateway" "myapp-igw" {
    vpc_id = var.vpc_id
    tags = {
        Name = "${var.env_prefix}-igw"
    }
}

resource "aws_default_route_table" "main-rtb" {
    default_route_table_id = var.default_route_table_id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.myapp-igw.id
    }
    tags = {
        Name = "${var.env_prefix}-main-rtb"
    }
}
