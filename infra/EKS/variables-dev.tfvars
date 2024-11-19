cluster_name    = "eks-dev"
vpc_name        = "vpc-dev"
vpc_cidr        = "10.2.0.0/16"
azs             = ["ap-southeast-1a", "ap-southeast-1b"]
public_subnets  = ["10.2.32.0/20", "10.2.64.0/20"]
private_subnets = ["10.2.80.0/20", "10.2.96.0/20"]
