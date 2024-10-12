terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.41.0"
    }
    kubectl = {
      source = "gavinbunney/kubectl"
      version = "1.14.0"
    }
  }

  backend "s3" {
    bucket         = "grupo9-terraform-test"
    dynamodb_table = "terraform_state"
    key            = "pin2"
    region         = "us-east-1"
  }

  # backend "pg" {
  #   conn_str = "postgres://PGUSER:PGPASSWORD@PGURL/PGDB"
  # }

}

provider "aws" {
  region = "us-east-1"
}

provider "helm" {
  kubernetes {
    host                   = aws_eks_cluster.example.endpoint
    cluster_ca_certificate = base64decode(aws_eks_cluster.example.certificate_authority.0.data)
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      args        = ["eks", "get-token", "--cluster-name", aws_eks_cluster.example.name]
      command     = "aws"
    }
  }
}

# Same parameters as kubernetes provider
provider "kubectl" {
  load_config_file       = false
  host                   = aws_eks_cluster.example.endpoint
  cluster_ca_certificate = base64decode(aws_eks_cluster.example.certificate_authority.0.data)
}