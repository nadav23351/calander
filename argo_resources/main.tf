terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
    argocd = {
      source  = "argoproj-labs/argocd"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region     = var.region
  access_key = var.access_key
  secret_key = var.secret_key
}


#### cluster resources
data "aws_eks_cluster" "stagingCluster" {
  name = var.clustername
}

data "aws_eks_cluster_auth" "clusterAuth" {
  name = var.clustername
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.stagingCluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.stagingCluster.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.clusterAuth.token
  # load_config_file       = false
}

provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.stagingCluster.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.stagingCluster.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.clusterAuth.token
  }
}

resource "kubernetes_manifest" "cluster_issuer_staging" {
    manifest = yamldecode(file("letsencrypt_staging.yaml"))
}

resource "kubernetes_manifest" "cluster_issuer_prod" {
    manifest = yamldecode(file("letsencrypt_prod.yaml"))
}

resource "helm_release" "argocd" {
  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = "5.34.1"
  namespace        = "argocd"
  create_namespace = true

  values = [file("argo-values.yaml")]

  set_sensitive {
    name  = "configs.secret.argocdServerAdminPassword"
    value = bcrypt(var.argoadminpassword)
  }

  lifecycle {
    ignore_changes = [
      set_sensitive, # Ignore changes to sensitive values
      metadata,      # Ignore changes to metadata
    ]
  }

  depends_on = [ kubernetes_manifest.cluster_issuer_prod ]
}

# Configure the Argo CD provider
provider "argocd" {
  server_addr = "argocd.nadav.online" 
  username    = "admin"
  password    = var.argoadminpassword
  insecure    = true
}

# Add the GitHub repository to Argo CD
resource "argocd_repository" "github_repo" {
  repo = "https://github.com/nadav23351/calander" # Replace with your GitHub repository URL
  username = var.github_username
  password = var.github_token
  depends_on = [helm_release.argocd]  
}
