resource "aws_iam_role" "eks_cluster_role" {
  name = "eks-cluster-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "eks_cluster_policy_attachment" {
  role       = aws_iam_role.eks_cluster_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}


resource "aws_iam_role" "eks_nodegroup_role" {
  name = "eks-nodegroup-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "eks_cluster_policy_attachment_1" {
  role       = aws_iam_role.eks_nodegroup_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_iam_role_policy_attachment" "eks_cluster_policy_attachment_2" {
  role       = aws_iam_role.eks_nodegroup_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role_policy_attachment" "eks_cluster_policy_attachment_3" {
  role       = aws_iam_role.eks_nodegroup_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_eks_cluster" "example" {
  name     = "eks-cluster-grupo9"
  role_arn = aws_iam_role.eks_cluster_role.arn
  version = "1.30"

  vpc_config {
    subnet_ids = ["subnet-0d17eaab166a49247", "subnet-0d99949f2e7cf43f1"]
    security_group_ids = ["sg-0b114040fe4636ab0"]
    endpoint_public_access = true
  }

  access_config {
    authentication_mode                         = "API_AND_CONFIG_MAP"
    bootstrap_cluster_creator_admin_permissions = true
    
  }

}


resource "aws_eks_node_group" "example" {
  cluster_name    = aws_eks_cluster.example.name
  node_group_name = "node-group-eks"
  node_role_arn   = aws_iam_role.eks_nodegroup_role.arn
  subnet_ids      = ["subnet-0d17eaab166a49247", "subnet-0d99949f2e7cf43f1"]
  capacity_type = "ON_DEMAND"

  instance_types = ["t3.medium"]

  scaling_config {
    desired_size = 2
    max_size     = 3
    min_size     = 1
  }

  update_config {
    max_unavailable = 1
  }

    depends_on = [ aws_iam_role_policy_attachment.eks_cluster_policy_attachment_1,aws_iam_role_policy_attachment.eks_cluster_policy_attachment_2, aws_iam_role_policy_attachment.eks_cluster_policy_attachment_3 ]

}

# resource "helm_release" "prometheus" {
#   name       = "prometheus"
#   repository = "https://prometheus-community.github.io/helm-charts"
#   chart      = "prometheus"
#   namespace  = "prometheus"

#   create_namespace = true  # Crea el namespace automáticamente

#   set {
#     name  = "alertmanager.persistentVolume.storageClass"
#     value = "gp2"
#   }

#   set {
#     name  = "server.persistentVolume.storageClass"
#     value = "gp2"
#   }
#   depends_on = [ helm_release.aws-ebs-csi-driver ]
# }

# resource "helm_release" "aws-ebs-csi-driver" {
#   name       = "aws-ebs-csi-driver"
#   repository = "https://kubernetes-sigs.github.io/aws-ebs-csi-driver"
#   chart      = "aws-ebs-csi-driver"
#   namespace  = "kube-system"
# }


output "endpoint" {
  value = aws_eks_cluster.example.endpoint
}

output "kubeconfig-certificate-authority-data" {
  value = aws_eks_cluster.example.certificate_authority[0].data
}