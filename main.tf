provider "aws" {
  region = "ap-south-1"
}

variable vpc_cidr_block{}
variable subnet_cidr_block{}
variable avail_zone{}
variable env_prefix{}// for every resouce we are creatin make a prefix for the evn 
// that it will be deployed to
variable my_ip{} 
variable instance_type{}

resource "aws_vpc" "myapp-vpc" {
  cidr_block = var.vpc_cidr_block
  tags = {
    Name = "${var.env_prefix}-vpc"
  }
}

resource "aws_subnet" "myapp-subnet-1" {
  vpc_id            = aws_vpc.myapp-vpc.id
  cidr_block        = var.subnet_cidr_block
  availability_zone = var.avail_zone
  tags = {
    Name = "${var.env_prefix}-subent-1"
  }
}

// create  new route table not use the default one
/*resource "aws_route_table" "myapp-route-table"{
  vpc_id = aws_vpc.myapp-vpc.id // which vpc this RT belongs to 
  route {
    cidr_block = "0.0.0.0/0"// all all ip addresses
    gateway_id = aws_internet_gateway.myapp-IgateWay.id
    // here we are referencing intenet gateway here in our route table
   } 
   tags = {// naming our resouces for better understand of whole does this belong
      Name : "${var.env_prefix}-rtb"
    }
}
*/

//creating resource intenet gateway 
resource "aws_internet_gateway" "myapp-IgateWay"{
 vpc_id =  aws_vpc.myapp-vpc.id 
 tags = {// naming our resouces for better understand of whole does this belong
      Name : "${var.env_prefix}-rtb"
    }
}
/* // explicit subnet assocation with our route table 
resource "aws_route_table_association" "a-rtb-subnet"{
  subnet_id = aws_subnet.myapp-subnet-1.id
  route_table_id = aws_route_table.myapp-route-table.id
}
*/
resource "aws_default_route_table" "main_rtb"{
  default_route_table_id = aws_vpc.myapp-vpc.default_route_table_id// get through vpcid 
  route {
    cidr_block = "0.0.0.0/0"// all all ip addresses
    gateway_id = aws_internet_gateway.myapp-IgateWay.id
    // here we are referencing intenet gateway here in our route table
   } 
   tags = {// naming our resouces for better understand of whole does this belong
      Name : "${var.env_prefix}-main-rtb"
    }
}

// in order to create security group 
resource "aws_security_group" "myapp-sg"{
  name = "myapp-sg"
  // we need to associate the security gropu with the vpc so that the server
  //inside the vpc can be associated with the security group
  vpc_id = aws_vpc.myapp-vpc.id
  //now definign the firewall rules in the security group
  // two type of request 1. inbound , 2.outbound traffic
  // inbound = ssh into EC2 ,access from the browser
  ingress{//inbound
    from_port = 22 // range of ports u want to open from -:> to 
    to_port = 22
    protocol = "TCP"
    cidr_blocks = [var.my_ip] //list of ip address that are allowed to access port defined above
    // who is allowed to access resources in port 22 . 
    // mention your laptop ipaddress
  }
  ingress{
    from_port = 8080
    to_port = 8080
    protocol = "TCP"
    cidr_blocks = ["0.0.0.0/0"]//we want any one to access this from the browser
   // any ip address can access that server on port 8080
  }

  //exiting traffic rule .outgoing traffic  
  egress{// installation or fetching docker images .
    // request going out of out private server 
    //allow that request to leave the vpc and we dont want to restrict it on any port

    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    prefix_list_ids = []//allowing VPc end points
  }
  tags = {// naming our resouces for better understand of whole does this belong
      Name : "${var.env_prefix}-sg"
    }
}
/*
data "aws_ami" "latest-amazon-linux-image"{
  most_recent = true
  owners = ["amazon"]
  filter {
    name = "name"// 
    values = ["amzn2-ami-kernel-*-x86_64-gp2"]// for name what values we want to filter on . 
  }// this will give us all the images which matches this regular expression . 
  //and give me the most recent of those . 
  filter{
    name = "virtulization-type"
    values = ["hvm"]
  }// this way we dont need to worry about hardcoding the value of what image i need 
}
*/
data "aws_ami" "latest-amazon-linux-image" {
  most_recent = true
  owners = ["amazon"]
  filter {
    name = "name"
    values = ["amzn2-ami-kernel-*-x86_64-gp2"]
  }
filter {
  name = "virtualization-type"
  values = ["hvm"]
  }
}
/*

output "aws_ami_id"{// we can see the output of aws_ami // use terraform plan= to see the image id 
  value = data.aws_ami.latest-amazon-linux-image.id  
}

resource "aws_instance" "myapp-server"{
  ami = data.aws_ami.latest-amazon-linux-image.id//is the image which the ec2 server will be based on or OS image

  instance_type = var.instance_type

  // first we have subnetid 
  // we want our ec2 endup in our subnet 
  subnet_id = aws_subnet.myapp-subnet-1.id

  //vpc security group ids
   vpc_security_group_ids = [aws_security_group.myapp-sg.id]
   availability_zone = var.avail_zone//taking from the variable already defined
   associate_public_ip_address = true // we need to access this instance from the browser 
   //as well as ssh into it 
   // so we need a public ip address of the server . 
   key_name = "terraform-server-key-pair"

   tags = {// naming our resouces for better understand of whole does this belong
      Name : "${var.env_prefix}-server"
    }
}
*/

output "aws_ami_id" {
  value = data.aws_ami.latest-amazon-linux-image.id 
  }
  
  resource "aws_instance" "myapp-server" {
  ami = data.aws_ami.latest-amazon-linux-image.id
  instance_type = var.instance_type
  subnet_id=aws_subnet.myapp-subnet-1.id
  vpc_security_group_ids = [aws_security_group.myapp-sg.id]
  availability_zone = var.avail_zone
  
  associate_public_ip_address = true
  
  key_name = "terraform-server-key-pair"
  
  tags = {// naming our resouces for better understand of whole does this belong
      Name : "${var.env_prefix}-server"
    }
}


