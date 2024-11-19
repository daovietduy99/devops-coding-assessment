variable "cluster_name" {
  description = "The name of the EKS cluster"
  default     = "my-cluster"
}

variable "vpc_name" {
  description = "Name to be used on all the resources as identifier"
  default     = ""
}

variable "vpc_cidr" {
  description = "The CIDR block for the VPC. Default value is a valid CIDR, but not acceptable by AWS and should be overridden"
  default     = "0.0.0.0/0"
}

variable "public_subnets" {
  description = "A list of subnet IDs"
  type        = list(string)
}

variable "private_subnets" {
  description = "A list of subnet IDs"
  type        = list(string)
}

variable "azs" {
  description = "A list of available regions"
  type        = list(string)
}

variable "map_public_ip_on_launch" {
  description = "Should be false if you do not want to auto-assign public IP on launch"
  default     = true
}
