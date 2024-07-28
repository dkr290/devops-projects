resource "aws_eip" "natEip" {
  for_each = local.natEips
  domain   = each.value.domain
}


resource "aws_nat_gateway" "nat" {
  for_each      = local.natGws
  allocation_id = each.value.allocation_id
  subnet_id     = each.value.subnet_id

  tags       = each.value.tags
  depends_on = [resource.aws_internet_gateway.MyIGW]
}

resource "aws_internet_gateway" "MyIGW" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "MyIGW"
  }
}
resource "aws_route_table" "MyPublicRoute" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.MyIGW.id
  }


  tags = {
    Name = "MyPublicRoute"
  }
}
resource "aws_route_table_association" "publicSubnet" {
  for_each       = local.publicRouteAssociation
  subnet_id      = each.value.subnet_id
  route_table_id = each.value.route_table_id
}
resource "aws_route_table" "PrivateRoutes" {
  for_each = local.privateRoutes
  vpc_id   = each.value.vpc_id

  dynamic "route" {
    for_each = each.value.route
    content {
      cidr_block = route.value.cidr_block
      gateway_id = route.value.gateway_id
    }
  }
  tags = each.value.tags

}
resource "aws_route_table_association" "privateSubnetApp" {
  for_each       = local.privateSubnetAppAssociation
  subnet_id      = each.value.subnet_id
  route_table_id = each.value.route_table_id
}
resource "aws_route_table_association" "privateSubnetDb" {
  for_each       = local.privateSubnetDbAssotiation
  subnet_id      = each.value.subnet_id
  route_table_id = each.value.route_table_id
}

