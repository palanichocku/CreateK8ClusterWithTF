resource "aws_vpc" "pc_vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_hostnames = true

  tags = {
   Name = "pc-k8-vpc"
 }
}

resource "aws_subnet" "pc_subnet_1" {
  vpc_id                  = aws_vpc.pc_vpc.id
  cidr_block              = "10.0.0.0/20"
  availability_zone       = "us-east-2a"
  map_public_ip_on_launch = true

  tags = {
   Name = "pc-k8-subnet1"
 }

}

resource "aws_subnet" "pc_subnet_2" {
  vpc_id                  = aws_vpc.pc_vpc.id
  cidr_block              = "10.0.16.0/20"
  availability_zone       = "us-east-2b"
  map_public_ip_on_launch = true

  tags = {
   Name = "pc-k8-subnet2"
 }
}

resource "aws_subnet" "pc_subnet_3" {
  vpc_id                  = aws_vpc.pc_vpc.id
  cidr_block              = "10.0.32.0/20"
  availability_zone       = "us-east-2c"
  map_public_ip_on_launch = true

  tags = {
   Name = "pc-k8-subnet3"
 }
}

resource "aws_internet_gateway" "pc_internet_gw" {
  vpc_id = aws_vpc.pc_vpc.id

  tags = {
   Name = "pc-k8-ig"
 }

}

resource "aws_route_table" "pc_route_table" {
  vpc_id = aws_vpc.pc_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.pc_internet_gw.id
  }

  route {
    cidr_block = "10.0.0.0/16"
    gateway_id = "local"
  }

  tags = {
   Name = "pc-k8-rt"
 }
}

resource "aws_route_table_association" "pc_subnet_1_association"{
  subnet_id = aws_subnet.pc_subnet_1.id
  route_table_id = aws_route_table.pc_route_table.id 
}

resource "aws_route_table_association" "pc_subnet_2_association"{
  subnet_id = aws_subnet.pc_subnet_2.id
  route_table_id = aws_route_table.pc_route_table.id 
}

resource "aws_route_table_association" "pc_subnet_3_association"{
  subnet_id = aws_subnet.pc_subnet_3.id
  route_table_id = aws_route_table.pc_route_table.id 
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = "pc-k8-cluster"
  cluster_version = "1.30"

  cluster_endpoint_public_access = true
  enable_cluster_creator_admin_permissions = true
  bootstrap_self_managed_addons  = true //PC added this after debugging. Not in YT/GitHub repos

  cluster_addons = {
    coredns                = {}
    eks-pod-identity-agent = {}
    kube-proxy             = {}
    vpc-cni                = {}
  }

  vpc_id                   = aws_vpc.pc_vpc.id
  subnet_ids               = [aws_subnet.pc_subnet_1.id, aws_subnet.pc_subnet_2.id, aws_subnet.pc_subnet_3.id]
  control_plane_subnet_ids = [aws_subnet.pc_subnet_1.id, aws_subnet.pc_subnet_2.id, aws_subnet.pc_subnet_3.id]


  eks_managed_node_groups = {
    pc_node = {
      min_size       = 1
      max_size       = 1
      desired_size   = 1
      instance_types = ["t2.medium"]
    }
  }
}