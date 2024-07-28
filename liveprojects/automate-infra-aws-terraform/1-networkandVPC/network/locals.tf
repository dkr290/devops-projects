locals {
  public_subnets = {
    publicA = var.publicA

    publicB = var.publicB

    publicC = var.publicC
  }
  private_app_subnets = {
    appA = var.AppA
    appB = var.AppB
    appC = var.AppC

  }
  private_db_subnets = {
    DbA = var.DbA
    DbB = var.DbB
    DbC = var.DbC

  }
  natEips = {
    natEipA = var.natEipA
    natEipB = var.natEipB
    natEipC = var.natEipC

  }

  natGws = {
    natGwA = {
      allocation_id = aws_eip.natEip["natEipA"].id
      subnet_id     = aws_subnet.public["publicA"].id
      tags = {
        Name = "natA"
      }


    }
    natGwB = {
      allocation_id = aws_eip.natEip["natEipB"].id
      subnet_id     = aws_subnet.public["publicB"].id
      tags = {
        Name = "natB"
      }

    }
    natGwC = {
      allocation_id = aws_eip.natEip["natEipC"].id
      subnet_id     = aws_subnet.public["publicC"].id
      tags = {
        Name = "natC"
      }

    }
  }
  publicRouteAssociation = {
    publicA = {
      subnet_id      = aws_subnet.public["publicA"].id
      route_table_id = aws_route_table.MyPublicRoute.id
    }
    publicB = {
      subnet_id      = aws_subnet.public["publicB"].id
      route_table_id = aws_route_table.MyPublicRoute.id
    }
    publicC = {
      subnet_id      = aws_subnet.public["publicC"].id
      route_table_id = aws_route_table.MyPublicRoute.id
    }


  }

  privateSubnetAppAssociation = {
    appA = {
      subnet_id      = aws_subnet.privateApp["appA"].id
      route_table_id = aws_route_table.PrivateRoutes["myPrivateRouteA"].id
    }
    appB = {
      subnet_id      = aws_subnet.privateApp["appB"].id
      route_table_id = aws_route_table.PrivateRoutes["myPrivateRouteB"].id

    }

    appC = {
      subnet_id      = aws_subnet.privateApp["appC"].id
      route_table_id = aws_route_table.PrivateRoutes["myPrivateRouteC"].id

    }

  }

  privateSubnetDbAssotiation = {
    DbA = {
      subnet_id      = aws_subnet.privateDb["DbA"].id
      route_table_id = aws_route_table.PrivateRoutes["myPrivateRouteA"].id

    }
    DbB = {
      subnet_id      = aws_subnet.privateDb["DbB"].id
      route_table_id = aws_route_table.PrivateRoutes["myPrivateRouteB"].id

    }
    DbC = {
      subnet_id      = aws_subnet.privateDb["DbC"].id
      route_table_id = aws_route_table.PrivateRoutes["myPrivateRouteC"].id

    }
  }



  privateRoutes = {
    myPrivateRouteA = {
      vpc_id = aws_vpc.main.id
      route = [
        {
          cidr_block = "0.0.0.0/0"
          gateway_id = aws_nat_gateway.nat["natGwA"].id
        }
      ]
      tags = {
        Name = "PrivateRouteA"
      }

    }
    myPrivateRouteB = {
      vpc_id = aws_vpc.main.id
      route = [
        {
          cidr_block = "0.0.0.0/0"
          gateway_id = aws_nat_gateway.nat["natGwB"].id
        }
      ]
      tags = {
        Name = "PrivateRouteB"
      }

    }

    myPrivateRouteC = {
      vpc_id = aws_vpc.main.id
      route = [
        {
          cidr_block = "0.0.0.0/0"
          gateway_id = aws_nat_gateway.nat["natGwC"].id
        }
      ]
      tags = {
        Name = "PrivateRouteC"
      }

    }
  }

}

