provider "aws" {
  region = "eu-north-1"
}

terraform {
  backend "s3" {
    bucket = "terraform-7158"
    region = "eu-north-1"
    key = "terraform.tfstate"
    
  }
}


#create vpc
resource "aws_vpc" "new_vpc1" {
  cidr_block = var.cidr
  tags = {
    Name=var.vpcname
  }
}

#create public subnet
resource "aws_subnet" "public_subnet" {
  vpc_id = aws_vpc.new_vpc1.id
  cidr_block = "172.25.0.0/20"
  map_public_ip_on_launch = true
  tags = {
    Name=var.public_subnet
  }
}

#create private subnet
resource "aws_subnet" "private_subnet" {
  vpc_id = aws_vpc.new_vpc1.id
  cidr_block = "172.25.16.0/20"
  map_public_ip_on_launch = false
  tags = {
    Name="private_subnet"
  }
}

#create internet gateway
resource "aws_internet_gateway" "new_vpc1_igw" {
  vpc_id = aws_vpc.new_vpc1.id
  tags = {
    Name="new_vpc1_igw"
  }
}

#create route table
resource "aws_route_table" "new_vpc1_route_table" {
    vpc_id = aws_vpc.new_vpc1.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.new_vpc1_igw.id

    }

    tags = {
        Name = "new_vpc1_route_table"
    }
}


#subnet association with route table
resource "aws_route_table_association" "public_sub_with_route" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.new_vpc1_route_table.id

}

/*data "aws_security_group" "sec-group" {
    
    filter {
      name="group-name"
      values = [ "sec-group" ]
    }
}
*/

#create security group
resource "aws_security_group" "my_sec_group" {
  name        = "my_sec_group"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.new_vpc1.id

  ingress {
    description = "TLS from VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

   ingress {
    description = "TLS from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks =  ["0.0.0.0/0"]
  }

  tags = {
    Name = "my_sec_group"
  }
}

#create instance 
resource "aws_instance" "terraform" {
  ami = "ami-0c1ac8a41498c1a9c"
  instance_type = var.instance_type
  key_name = "newins"
  vpc_security_group_ids = [aws_security_group.my_sec_group.id]
  subnet_id = [aws_subnet.public_subnet.id]
  

  tags = {
    Name = "Vpc_instance"
  }
}



