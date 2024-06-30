
# variable vpc_cidr_block{}
# variable subnet_cidr_block{} 
# variable avail_zone{}// avail zone and env we need in this as well 
# variable env_prefix{}// for every resouce we are creatin make a prefix for the evn 
# // that it will be deployed to
# variable my_ip{} 
# variable instance_type{}
# variable my_public_key_location{}
# variable image_name{} // from webserver module 



variable vpc_cidr_block {}
variable subnet_cidr_block {}
variable avail_zone {}
variable env_prefix {}
variable my_ip {}
variable instance_type {}
variable public_key_location {}
variable private_key_location{}
variable image_name {}