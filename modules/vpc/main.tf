data "aws_availability_zones" "azs" {}

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name        = "${var.projectname}-vpc"
    Environment = var.environment
  }
}

resource "aws_subnet" "public" {
  count                   = local.count
  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 8, count.index + 1)
  availability_zone       = data.aws_availability_zones.azs.names[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name        = "${var.projectname}-public-subnet${count.index + 1}"
    Environment = var.environment
  }
}

resource "aws_subnet" "private" {
  count             = local.count
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, count.index + 10)
  availability_zone = data.aws_availability_zones.azs.names[count.index]

  tags = {
    Name        = "${var.projectname}-private-subnet${count.index + 1}"
    Environment = var.environment
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name        = "${var.projectname}-igw"
    Environment = var.environment
  }
}

resource "aws_eip" "eip" {
  domain = "vpc"

  tags = {
    Name        = "${var.projectname}-eip"
    Environment = var.environment
  }
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.eip.id
  subnet_id     = aws_subnet.public[0].id
  tags = {
    Name        = "${var.projectname}-nat"
    Environment = var.environment
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = var.default-route
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name        = "${var.projectname}-public-route"
    Environment = var.environment
  }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = var.default-route
    gateway_id = aws_nat_gateway.nat.id
  }

  tags = {
    Name = "${var.projectname}-private-route"
  }
}

resource "aws_route_table_association" "public" {
  count          = local.count
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private" {
  count          = local.count
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}