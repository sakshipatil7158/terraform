#input variable
variable "instance_type" {
  default = "t3.micro"
}

variable "vpcname" {
  default = "vpc1"
}

variable "cidr" {
  default = "172.25.0.0/16"
}

variable "public_subnet" {
  default = "pub_subnet"
}