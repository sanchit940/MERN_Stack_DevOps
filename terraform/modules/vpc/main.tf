# --------VPC-----------------
resource "aws_vpc" "main_vpc" {
  cidr_block = var.cidr_block_range
  enable_dns_hostnames = true
  enable_dns_support = true
  tags= {
    Name= "main"

  }
}

#-------------SUBNETS--------------------

resource "aws_subnet" "public_subnet" {  
  count = length(var.public_subnet_range)
  vpc_id = aws_vpc.main_vpc.id
  cidr_block = var.public_subnet_range[count.index]
  availability_zone = var.availability_zone_list[count.index% length(var.availability_zone_list)]
  map_public_ip_on_launch = true
  
  tags = {
    Name= "public-subnet-${count.index}"
    "kubernetes.io/role/elb" = "1"
    "kubernetes.io/cluster/mern-stack-cluster" = "shared"

  }
  
}

resource "aws_subnet" "private_subnet" {
  count = length(var.private_subnet_range)
  vpc_id = aws_vpc.main_vpc.id
  cidr_block = var.private_subnet_range[count.index]
  availability_zone = var.availability_zone_list[count.index % length(var.availability_zone_list)]
  tags = {
    Name= "private-subnet-${count.index}"
    "kubernetes.io/role/internal-elb" = "1"
    "kubernetes.io/cluster/mern-stack-cluster" = "shared"

  }

  
}
#------------ROUTE-TABLES------------------------
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.main_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main_igw.id

  }
}
resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.main_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.main_nat_gateway.id
  }

}

resource "aws_route_table_association" "private" {
  count = length(var.private_subnet_range)
  route_table_id = aws_route_table.private_route_table.id
  subnet_id = aws_subnet.private_subnet[count.index].id
    
}


resource "aws_route_table_association" "public" {
  route_table_id = aws_route_table.public_route_table.id
  count = length(var.public_subnet_range)
  subnet_id = aws_subnet.public_subnet[count.index].id
    
}
#--------------IGW---------------------------
resource "aws_internet_gateway" "main_igw" {
  vpc_id = aws_vpc.main_vpc.id
  
}
#----------EIP and NAT-------------------------------
resource "aws_eip" "nat" {
  domain = "vpc"

  
}
resource "aws_nat_gateway_eip_association" "nat_eip" {
  allocation_id = aws_eip.nat.id
  nat_gateway_id = aws_nat_gateway.main_nat_gateway.id  
}

resource "aws_nat_gateway" "main_nat_gateway" {
  vpc_id = aws_vpc.main_vpc.id
  allocation_id = aws_eip.nat.id
  subnet_id = aws_subnet.public_subnet[0].id
  availability_mode = "regional"
  depends_on = [ aws_internet_gateway.main_igw ]
}
