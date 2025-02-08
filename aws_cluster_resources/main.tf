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


resource "helm_release" "ingress_nginx" {
  name       = "opeth"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"

  set {
    name  = "controller.metrics.enabled"
    value = "true"
  }
  set {
    name  = "controller.metrics.service.annotations.prometheus\\.io/scrape"
    value = "true"
    type  = "string"
  }
  set {
    name  = "controller.metrics.service.annotations.prometheus\\.io/port"
    value = "10254"
    type  = "string"
  }
  set {
    name  = "defaultBackend.enabled"
    value = "true"
  }
  set {
    name  = "controller.service.type"
    value = "LoadBalancer"
  }
  set {
    name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-backend-protocol"
    value = "tcp"
    type  = "string"
  }
  set {
    name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-cross-zone-load-balancing-enabled"
    value = "true"
  }
  set {
    name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-type"
    value = "nlb"
    type  = "string"
  }
}

resource "helm_release" "cert_manager" {
  name             = "cert-manager"
  chart            = "cert-manager"
  repository       = "https://charts.jetstack.io"
  namespace        = "cert-manager"
  create_namespace = true
  set {
    name  = "installCRDs"
    value = "true"
  }
  depends_on = [ helm_release.ingress_nginx ]
}

resource "kubernetes_secret" "cf_token" {
  metadata {
    name      = "cloudflare-api-token"
    namespace = helm_release.cert_manager.namespace
  }
  data = {
    secret = var.cf_api_token
  }
  type = "Opaque"
}

resource "kubernetes_manifest" "cluster_issuer_staging" {
    manifest = yamldecode(file("letsencrypt_staging.yaml"))

    depends_on = [ 
      kubernetes_secret.cf_token, 
      helm_release.cert_manager
    ]
}

resource "kubernetes_manifest" "cluster_issuer_prod" {
    manifest = yamldecode(file("letsencrypt_prod.yaml"))

    depends_on = [ 
      kubernetes_secret.cf_token, 
      helm_release.cert_manager
    ]
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
  repo = "https://github.com/faizananwar532/calendar-app" # Replace with your GitHub repository URL
  username = var.github_username
  password = var.github_token
  depends_on = [helm_release.argocd]  
}
