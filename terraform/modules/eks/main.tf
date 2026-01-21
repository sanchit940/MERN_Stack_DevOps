resource "aws_iam_role" "cluster_node_role" {
    assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "eks.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })  
}

resource "aws_iam_role_policy_attachment" "cluster_node_attach" {
    role =aws_iam_role.cluster_node_role.name
    policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  
}


resource "aws_iam_role" "worker_node_role" {
    assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })
}

locals {
  eks_nodegroup_policies = {
    EKSWorkerNodePolicy="arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
    EKS_CNI_Policy="arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy",
    EC2ContainerRegistryReadOnly="arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly",
    EBSCSIDriverPolicy="arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
    
    }
} 


resource "aws_iam_role_policy_attachment" "worker_node_attach" {
    for_each = local.eks_nodegroup_policies
    role = aws_iam_role.worker_node_role.name
    policy_arn = each.value

  
}

data "tls_certificate" "eks" {
  url = aws_eks_cluster.cluster_node.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "eks" {
  url             = aws_eks_cluster.cluster_node.identity[0].oidc[0].issuer
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.eks.certificates[0].sha1_fingerprint]
}

resource "aws_eks_cluster" "cluster_node" {
    name = "mern-stack-cluster"
    role_arn = aws_iam_role.cluster_node_role.arn
    version = var.kubernetes_version

    vpc_config {
      endpoint_private_access = true
      subnet_ids = var.private_subnet_ids
      endpoint_public_access = false
    }
  
}

resource "aws_eks_node_group" "worker_node" {
    for_each = var.scaling_config
    node_role_arn = aws_iam_role.worker_node_role.arn
    cluster_name = aws_eks_cluster.cluster_node.name
    node_group_name = each.key
    instance_types = [var.ec2_instance_type]
    scaling_config {
    desired_size = each.value.desired_size
    max_size     = each.value.max_size
    min_size     = each.value.min_size

        
      
    }

    subnet_ids = var.private_subnet_ids
    disk_size = 45

  depends_on = [ aws_eks_cluster.cluster_node,
  aws_iam_role.cluster_node_role,
  aws_iam_role_policy_attachment.worker_node_attach ]
}

resource "aws_eks_addon" "addons" {
    for_each = var.eks_addons
    cluster_name = aws_eks_cluster.cluster_node.name
    addon_name = each.key
    addon_version = each.value
    depends_on = [ aws_eks_node_group.worker_node ]
}

