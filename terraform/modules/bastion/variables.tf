variable "eks_cluster_sg" {
  type = string
}
variable "vpc_id" {
    type = string
  
}
variable "public_subnet_ids" {
  type = list(string)
}

variable "bastion_subnet_index" {
  type    = number
  default = 0
}
