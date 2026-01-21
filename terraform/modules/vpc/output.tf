output "public_subnet_ids" {
    description = "public subnet ids from vpc module"
    value = aws_subnet.public_subnet[*].id
}

output "main_vpc_id" {
    value = aws_vpc.main_vpc.id
  
}

output "private_subnet_ids" {
    description = "private subnet ids from vpc module"
    value = aws_subnet.private_subnet[*].id
  
}

