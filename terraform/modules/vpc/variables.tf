variable "cidr_block_range" {
  description = "CIDR block range"
  type = string
  default = "10.0.0.0/20"

}
variable "public_subnet_range" {
    description = "Public subnet range"
  type = list(string)
  default = ["10.0.3.0/24", "10.0.4.0/24"]
}

variable "private_subnet_range" {
    description = "private subnet range"
    type = list(string)
    default = [ "10.0.1.0/24", "10.0.2.0/24" ]
  
}

variable "availability_zone_list" {
    description = "AZ list"
  type = list(string)
  default = [ "ap-south-1a", "ap-south-1b" ]
}
