# // in order to create security group 
# resource "aws_security_group" "myapp-sg"{

#   // we need to associate the security gropu with the vpc so that the server
#   //inside the vpc can be associated with the security group
#   vpc_id = var.vpc_id // reset 
#   //now definign the firewall rules in the security group
#   // two type of request 1. inbound , 2.outbound traffic
#   // inbound = ssh into EC2 ,access from the browser
#   ingress{//inbound
#     from_port = 22 // range of ports u want to open from -:> to 
#     to_port = 22
#     protocol = "TCP"
#     cidr_blocks = [var.my_ip] //list of ip address that are allowed to access port defined above
#     // who is allowed to access resources in port 22 . 
#     // mention your laptop ipaddress
#   }
#   ingress{
#     from_port = 8080
#     to_port = 8080
#     protocol = "TCP"
#     cidr_blocks = ["0.0.0.0/0"]//we want any one to access this from the browser
#    // any ip address can access that server on port 8080
#   }

#   //exiting traffic rule .outgoing traffic  
#   egress{// installation or fetching docker images .
#     // request going out of out private server 
#     //allow that request to leave the vpc and we dont want to restrict it on any port

#     from_port = 0
#     to_port = 0
#     protocol = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#     prefix_list_ids = []//allowing VPc end points
#   }
#   tags = {// naming our resouces for better understand of whole does this belong
#       Name : "${var.env_prefix}-sg"
#     }
# }
# /*
# data "aws_ami" "latest-amazon-linux-image"{
#   most_recent = true
#   owners = ["amazon"]
#   filter {
#     name = "name"// 
#     values = ["amzn2-ami-kernel-*-x86_64-gp2"]// for name what values we want to filter on . 
#   }// this will give us all the images which matches this regular expression . 
#   //and give me the most recent of those . 
#   filter{
#     name = "virtulization-type"
#     values = ["hvm"]
#   }// this way we dont need to worry about hardcoding the value of what image i need 
# }
# */
# data "aws_ami" "latest-amazon-linux-image" {
#   most_recent = true
#   owners = ["amazon"]
#   filter {
#     name = "name"
#     values = [var.image_name]//reset
#   }
# filter {
#   name = "virtualization-type"
#   values = ["hvm"]
#   }
# }
# /*

# output "aws_ami_id"{// we can see the output of aws_ami // use terraform plan= to see the image id 
#   value = data.aws_ami.latest-amazon-linux-image.id  
# }

# resource "aws_instance" "myapp-server"{
#   ami = data.aws_ami.latest-amazon-linux-image.id//is the image which the ec2 server will be based on or OS image

#   instance_type = var.instance_type

#   // first we have subnetid 
#   // we want our ec2 endup in our subnet 
#   subnet_id = aws_subnet.myapp-subnet-1.id

#   //vpc security group ids
#    vpc_security_group_ids = [aws_security_group.myapp-sg.id]
#    availability_zone = var.avail_zone//taking from the variable already defined
#    associate_public_ip_address = true // we need to access this instance from the browser 
#    //as well as ssh into it 
#    // so we need a public ip address of the server . 
#    key_name = "terraform-server-key-pair"

#    tags = {// naming our resouces for better understand of whole does this belong
#       Name : "${var.env_prefix}-server"
#     }
# }
# */


  
#   resource "aws_instance" "myapp-server" {
#   ami = data.aws_ami.latest-amazon-linux-image.id
#   instance_type = var.instance_type
#   subnet_id=var.subnet_id //module.myapp-subnet.subnet.id// this will give us the object //this is how u can access the resouces 
#   //defined in another module . // reset now we dont have the acces to this module any more as this module is d
#   //  defined out side 
#   vpc_security_group_ids = [aws_security_group.myapp-sg.id]//[aws_security_group.myapp-sg.id] // reset 
#   availability_zone = var.avail_zone
  
#   associate_public_ip_address = true
  
#   key_name = aws_key_pair.ssh-key.key_name

#   //below adding ec2 user in docker group , port 8080 on host bind with port 80 on nginx
#   // we need to ensure that our instance get destroyed and recreated when we start our instace every time.
#   // for that we have documentaion aws_instance on terraform -> user_data_replace_on_change
#   // this block below will only get executed once .
#   user_data =file("entry-script.sh")

#   user_data_replace_on_change = true
            
#   tags = {// naming our resouces for better understand of whole does this belong
#       Name : "${var.env_prefix}-server"
#     }
# }

# resource "aws_key_pair" "ssh-key"{
#   key_name = "dev-server-key"
#   public_key = file(var.my_public_key_location)//a key pair must already exist locally on our machine 
# }

resource "aws_default_security_group" "default-sg" {
    vpc_id = var.vpc_id

    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = [var.my_ip]
    }

    ingress {
        from_port = 8080
        to_port = 8080
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
        prefix_list_ids = []
    }

    tags = {
        Name = "${var.env_prefix}-default-sg"
    }
}

data "aws_ami" "latest-amazon-linux-image" {
    most_recent = true
    owners = ["amazon"]
    filter {
        name = "name"
        values = [var.image_name]
    }
    filter {
        name = "virtualization-type"
        values = ["hvm"]
    }
}

resource "aws_key_pair" "ssh-key" {
    key_name = "server-key"
    public_key = file(var.public_key_location)
}

resource "aws_instance" "myapp-server" {
    ami = data.aws_ami.latest-amazon-linux-image.id
    instance_type = var.instance_type

    subnet_id = var.subnet_id
    vpc_security_group_ids = [aws_default_security_group.default-sg.id]
    availability_zone = var.avail_zone

    associate_public_ip_address = true
    key_name = aws_key_pair.ssh-key.key_name

    user_data = file("entry-script.sh")

    tags = {
        Name = "${var.env_prefix}-server"
    }
}

