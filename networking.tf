locals {
  azs = data.aws_availability_zones.available.names
}

data "aws_availability_zones" "available" {}

resource "random_id" "random" {
  byte_length = 2
}

resource "random_shuffle" "az_shuffle" {
  input        = data.aws_availability_zones.available.names
  result_count = var.value4subnet_deployment
}

resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "vpc-${random_id.random.dec}"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "gw-${random_id.random.dec}"
  }
}

resource "aws_default_route_table" "df_route_table" {
  default_route_table_id = aws_vpc.vpc.default_route_table_id

  tags = {
    Name = "dfprivate_route_table"
  }
}

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "route_table"
  }
}

resource "aws_route" "public_route" {
  route_table_id         = aws_route_table.public_route_table.id
  destination_cidr_block = var.public_route
  gateway_id             = aws_internet_gateway.gw.id
}

# resource "aws_subnet" "public_subnet" {
#     count = length(var.public_cidrs)
#     vpc_id = aws_vpc.vpc.id
#     cidr_block = var.public_cidrs[count.index]
#     map_public_ip_on_launch = true
#     availability_zone = data.aws_availability_zones.available.names[0]

#     tags = {
#         Name = "public_subnet-${count.index + 1}"
#     }

# } 

resource "aws_subnet" "public_subnet" {
  count                   = var.pub_subnet_cnt
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = [for i in range(2, 255, 2) : cidrsubnet(var.vpc_cidr, 8, i)][count.index]
  map_public_ip_on_launch = true
  availability_zone       = random_shuffle.az_shuffle.result[count.index]

  tags = {
    Name = "public_subnet-${count.index + 1}"
  }

}

resource "aws_subnet" "private_subnet" {
  count             = var.priv_subnet_cnt
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = [for i in range(1, 255, 2) : cidrsubnet(var.vpc_cidr, 8, i)][count.index]
  availability_zone = local.azs[count.index]

  tags = {
    Name = "private_subnet-${count.index + 1}"
  }
}

resource "aws_route_table_association" "public_association" {
  count          = var.pub_subnet_cnt
  subnet_id      = aws_subnet.public_subnet.*.id[count.index]
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_security_group" "security_group" {
  name        = "public_security_group"
  description = "security group for public instances"
  vpc_id      = aws_vpc.vpc.id

  dynamic "ingress" {
    for_each = var.ports
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = [var.access_from]
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.access_from]
  }


}