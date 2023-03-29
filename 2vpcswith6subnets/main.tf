resource "aws_vpc" "Myvpc" {
  cidr_block = var.aws_subnet_info.vpc_cidr
  tags = {
    Name = "Myvpc"
  }
}

resource "aws_subnet" "subnets" {
  count             = length(var.aws_subnet_info.subnet_names)
  cidr_block        = cidrsubnet(var.aws_subnet_info.vpc_cidr, 8, count.index)
  availability_zone = "${var.region}${var.aws_subnet_info.subnet_azs[count.index]}"
  vpc_id            = local.vpc_id
  tags = {
    Name = var.aws_subnet_info.subnet_names[count.index]
  }
  depends_on = [
    local.vpc_id
  ]
}

resource "aws_internet_gateway" "igw" {
  vpc_id = local.vpc_id
  tags = {
    "Name" = "ntier"
  }
  depends_on = [
    aws_internet_gateway.igw
  ]
}

resource "aws_route_table" "public" {
  vpc_id = local.vpc_id

  route {
    cidr_block = local.anywhere
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "public"
  }
  depends_on = [
    aws_subnet.subnets
  ]
}

resource "aws_route_table" "private" {
  vpc_id = local.vpc_id

  route {
    cidr_block = local.anywhere
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "private"
  }
  depends_on = [
    aws_subnet.subnets
  ]
}

data "aws_subnets" "public" {
  filter {
    name   = "tag:Name"
    values = var.aws_subnet_info.public_subnets
  }
  filter {
    name   = "vpc-id"
    values = [local.vpc_id]
  }
  depends_on = [
    aws_subnet.subnets
  ]
}

data "aws_subnets" "private" {
  filter {
    name   = "tag:Name"
    values = var.aws_subnet_info.private_subnets
  }
  filter {
    name   = "vpc-id"
    values = [local.vpc_id]
  }
  depends_on = [
    aws_subnet.subnets
  ]
}

resource "aws_route_table_association" "public" {
  count          = length(data.aws_subnets.public.ids)
  subnet_id      = data.aws_subnets.public.ids[count.index]
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private" {
  count          = length(data.aws_subnets.private.ids)
  subnet_id      = data.aws_subnets.private.ids[count.index]
  route_table_id = aws_route_table.private.id
}
