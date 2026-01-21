variable "kubernetes_version" {
    type = string
    default = "1.34"
  
}
variable "private_subnet_ids" {
    description = "value of private subnets from vpc module"
    type = list(string)
  
}
variable "scaling_config" {
    type = map(object({
       desired_size = number,
       max_size= number,
       min_size= number
    }))
  
  default = {
    mern-worker-node-1 = {
        desired_size= 3
        max_size= 5
        min_size= 2
    }

  }
}
variable "eks_addons" {
  type = map(string)
  default = {
    coredns             = "v1.12.2-eksbuild.4"
    kube-proxy          = "v1.33.0-eksbuild.2"
    vpc-cni             = "v1.20.0-eksbuild.1"
    aws-ebs-csi-driver  = "v1.46.0-eksbuild.1"
  }
}

variable "ec2_instance_type" {
    type = string
    description = "which type of ec2 instaces you want to use"
    default = "t3.medium"
  
}