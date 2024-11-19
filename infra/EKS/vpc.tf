resource "aws_vpc" "eks_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name                                        = var.vpc_name
    "kubernetes.io/cluster/${var.cluster_name}" = "Shared"
  }
}

resource "aws_internet_gateway" "eks_igw" {
  vpc_id = aws_vpc.eks_vpc.id

  tags = {
    Name = "eks-igw"
  }
}

resource "aws_route_table" "eks_public_rt" {
  vpc_id = aws_vpc.eks_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.eks_igw.id
  }

  tags = {
    Name = "eks-public-rt"
  }
}

# #################
# # Private subnet
# #################
# resource "aws_subnet" "eks_subnet" {
#   count = length(var.subnets) > 0 ? length(var.subnets) : 0

#   vpc_id                  = aws_vpc.eks_vpc.id
#   cidr_block              = var.subnets[count.index]
#   availability_zone       = element(var.azs, count.index)
#   map_public_ip_on_launch = var.map_public_ip_on_launch
#   tags = {
#     Name = "eks-subnet-${element(var.azs, count.index)}"
#   }
# }

# resource "aws_route_table_association" "eks_subnet_association" {
#   count          = length(aws_subnet.eks_subnet)
#   subnet_id      = aws_subnet.eks_subnet[count.index].id
#   route_table_id = aws_route_table.eks_public_rt.id
# }

# resource "aws_security_group" "eks_sg" {
#   vpc_id = aws_vpc.eks_vpc.id

#   ingress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   tags = {
#     Name = "eks-sg"
#   }
# }

# # resource "aws_vpc_security_group_ingress_rule" "allow_tls_ipv4" {
# #   security_group_id = aws_security_group.allow_tls.id
# #   cidr_ipv4         = aws_vpc.main.cidr_block
# #   from_port         = 443
# #   ip_protocol       = "tcp"
# #   to_port           = 443
# # }

#############################

resource "aws_subnet" "public_subnets" {
  count = length(var.public_subnets) > 0 ? length(var.public_subnets) : 0

  vpc_id                  = aws_vpc.eks_vpc.id
  cidr_block              = var.public_subnets[count.index]
  availability_zone       = element(var.azs, count.index)
  map_public_ip_on_launch = var.map_public_ip_on_launch
  tags = {
    Name                     = "${var.vpc_name}-public-subnet-${element(var.azs, count.index)}"
    "kubernetes.io/role/elb" = "1"
  }
}

resource "aws_route_table_association" "public_subnet_association" {
  count          = length(aws_subnet.public_subnets)
  subnet_id      = aws_subnet.public_subnets[count.index].id
  route_table_id = aws_route_table.eks_public_rt.id
}

resource "aws_security_group" "eks_sg" {
  vpc_id = aws_vpc.eks_vpc.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "eks-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "ingress_action_runner_controller_webhook_tcp" {
  description       = "Cluster to Actions Runner Controller webhook"
  security_group_id = aws_security_group.eks_sg.id
  cidr_ipv4         = aws_vpc.eks_vpc.cidr_block
  from_port         = 9443
  ip_protocol       = "tcp"
  to_port           = 9443
}

#################
# Private subnet
#################
resource "aws_subnet" "private_subnets" {
  count = length(var.private_subnets) > 0 ? length(var.private_subnets) : 0

  vpc_id            = aws_vpc.eks_vpc.id
  cidr_block        = var.private_subnets[count.index]
  availability_zone = element(var.azs, count.index)
  tags = {
    Name                              = "${var.vpc_name}-priv-subnet-${element(var.azs, count.index)}"
    "kubernetes.io/role/internal-elb" = "1"
  }
}

resource "aws_route_table" "private_rt" {
  count = length(var.private_subnets) > 0 ? length(var.private_subnets) : 0

  vpc_id = aws_vpc.eks_vpc.id

  tags = {
    Name = "rt-priv-subnet-${element(var.azs, count.index)}"
  }
}

resource "aws_route_table_association" "private_subnet_association" {
  count = aws_route_table.private_rt[*].id != null ? length(aws_route_table.private_rt[*].id) : 0

  subnet_id      = aws_subnet.private_subnets[count.index].id
  route_table_id = aws_route_table.private_rt[count.index].id
}

resource "aws_vpc_endpoint" "s3" {
  vpc_id            = aws_vpc.eks_vpc.id
  service_name      = "com.amazonaws.ap-southeast-1.s3"
  vpc_endpoint_type = "Gateway"
}

resource "aws_vpc_endpoint_route_table_association" "example" {
  count = aws_route_table.private_rt[*].id != null ? length(aws_route_table.private_rt[*].id) : 0

  route_table_id  = aws_route_table.private_rt[count.index].id
  vpc_endpoint_id = aws_vpc_endpoint.s3.id
}
