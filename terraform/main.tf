module "vpc" {
  source                 = "./modules/vpc"
  cidr_block_range       = "10.0.0.0/20"
  public_subnet_range    = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnet_range   = ["10.0.3.0/24", "10.0.4.0/24"]
  availability_zone_list = ["ap-south-1a", "ap-south-1b"]
}

module "eks" {
  source             = "./modules/eks"
  private_subnet_ids = module.vpc.private_subnet_ids
  ec2_instance_type  = "t3.medium"
  kubernetes_version = "1.34"
  eks_addons = {
    coredns            = "v1.11.1-eksbuild.4"
    kube-proxy         = "v1.29.0-eksbuild.1"
    vpc-cni            = "v1.16.0-eksbuild.1"
    aws-ebs-csi-driver = "v1.30.0-eksbuild.1"
  }
}