variable "access_key" {
  description = "AWS access key"
  sensitive   = true
}

variable "secret_key" {
  description = "AWS secret key"
  sensitive   = true
}

variable "region" {
  description = "AWS region"
  default     = "us-east-1"
}

variable "clustername" {
  default     = "staging"
  description = "EKS Cluster Name"
}

variable "cfmail" {
  description = "email used for cloudflare"
  sensitive   = true
}

variable "acmemail" {
  description = "email used for acme server"
  sensitive   = true
}

variable "argoadminpassword" {
  description = "argocd admin password"
  sensitive   = true
}

variable "github_token" {
  description = "github token used for authenticating repo"
  sensitive   = true
}

variable "github_username" {
  description = "github username used for authenticating repo"
  sensitive   = true
}

