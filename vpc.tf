locals {
  availaiblity_zone_names = data.aws_availability_zones.modetrans_availability_zones.names
  private_subnet_ids      = aws_subnet.modetrans_private_subnets.*.id
  public_subnet_ids       = aws_subnet.modetrans_public_subnets.*.id
}

resource "aws_vpc" "modetrans_vpc" {
  cidr_block           = var.vpc_cidr[var.region]
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "${var.application_name}-${var.application_environment[var.region]}-VPC"
  }
}

resource "aws_instance" "modetrans_bastion_host" {
  ami = var.ec2_amis[var.region]
  instance_type = "t2.micro"
  subnet_id = local.public_subnet_ids[0]
  vpc_security_group_ids = [
    aws_security_group.modetrans_bastion_sg.id
  ]
  key_name = "modetrans_kp"
  user_data = file(scripts/php.sh)

  tags = {
    Name = "${var.application_name}-${var.application_environment[var.region]}-Bastion"
  }
}

resource "aws_instance" "modetrans_private_nodes" {
  count = length(local.availaiblity_zone_names)
  ami = var.ec2_amis[var.region]
  instance_type = "t2.micro"
  subnet_id = local.public_subnet_ids[0]
  vpc_security_group_ids = [
    aws_security_group.modetrans_instance_sg.id
  ]
  key_name = "modetrans_kp"

  tags = {
    Name = "${var.application_name}-${var.application_environment[var.region]}-Instance${count.index + 1}"
  }
}

resource "aws_subnet" "modetrans_public_subnets" {
  count             = length(local.availaiblity_zone_names)
  vpc_id            = aws_vpc.modetrans_vpc.id
  cidr_block        = cidrsubnet(var.vpc_cidr[var.region], 12, count.index + 1)
  availability_zone = local.availaiblity_zone_names[count.index]
  tags = {
    Name = "${var.application_name}-${var.application_environment[var.region]}-PublicSubnet${count.index + 1}"
  }
}

resource "aws_subnet" "modetrans_private_subnets" {
  count             = length(local.availaiblity_zone_names)
  vpc_id            = aws_vpc.modetrans_vpc.id
  cidr_block        = cidrsubnet(var.vpc_cidr[var.region], 12, count.index + 5)
  availability_zone = local.availaiblity_zone_names[count.index]
  tags = {
    Name = "${var.application_name}-${var.application_environment[var.region]}-PrivateSubnet${count.index + 1}"
  }
}

resource "aws_internet_gateway" "modetrans_internet_gateway" {
  vpc_id = aws_vpc.modetrans_vpc.id

  tags = {
    Name = "${var.application_name}-${var.application_environment[var.region]}-IG"
  }
}

resource "aws_route_table" "modetrans_public_route" {
  vpc_id = aws_vpc.modetrans_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.modetrans_internet_gateway.id
  }

  tags = {
    Name = "${var.application_name}-${var.application_environment[var.region]}-PublicRouteTable"
  }
}

resource "aws_route_table_association" "modetrans_public_route_associations" {
  count          = length(local.availaiblity_zone_names)
  route_table_id = aws_route_table.modetrans_public_route.id
  subnet_id      = local.public_subnet_ids[count.index]
}

resource "aws_eip" "modetrans_eip" {
  vpc = true

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = "${var.application_name}-${var.application_environment[var.region]}-Elastic-IP"
  }
}

resource "aws_nat_gateway" "modetrans_nat_gateway" {
  allocation_id = aws_eip.modetrans_eip.id
  subnet_id     = local.public_subnet_ids[0]

  tags = {
    Name = "${var.application_name}-${var.application_environment[var.region]}-NAT-GW"
  }
}

resource "aws_route_table" "modetrans_private_route" {
  vpc_id = aws_vpc.modetrans_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.modetrans_nat_gateway.id
  }

  tags = {
    Name = "${var.application_name}-${var.application_environment[var.region]}-PrivateRouteTable"
  }
}

resource "aws_route_table_association" "modetrans_private_route_associations" {
  count          = length(local.availaiblity_zone_names)
  route_table_id = aws_route_table.modetrans_private_route.id
  subnet_id      = local.private_subnet_ids[count.index]
}

output "VPC_ID" {
  value = aws_vpc.modetrans_vpc.id
}

output "Private_Subnets" {
  value = {
    for private_subnet in aws_subnet.modetrans_private_subnets :
    private_subnet.tags.Name => private_subnet.id
  }
}
