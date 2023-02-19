variable "cyf-vpc-id" {
  description = "Target VPC for Deployment"
  type        = string
}

variable "cyf-localIP" {
  description = "Your local machine IP for use in the security group Ingress"
  type        = string
}

variable "cyf-public-key" {
  description = "The AWS SSH public key string which will be used to SSH into the machine"
  type        = string
}