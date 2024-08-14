locals {
  public_subnets = {
    publicA = var.publicA

    publicB = var.publicB

    publicC = var.publicC
  }
  private_workers_subnets = {
    WorkerA = var.WorkerA
    WorkerB = var.WorkerB
    WorkerC = var.WorkerC

  }
  private_db_subnets = {
    DbA = var.DbA
    DbB = var.DbB
    DbC = var.DbC

  }
  natEips = {
    natEipA = var.natEipA

  }

  natGws = {
    natGwA = {
      allocation_id = aws_eip.natEip["natEipA"].id
      subnet_id     = aws_subnet.public["publicA"].id
      tags = {
        Name = "natA"
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
    WorkerA = {
      subnet_id      = aws_subnet.workers["WorkerA"].id
      route_table_id = aws_route_table.PrivateRoutes["myPrivateRouteA"].id
    }
    WorkerB = {
      subnet_id      = aws_subnet.workers["WorkerB"].id
      route_table_id = aws_route_table.PrivateRoutes["myPrivateRouteB"].id

    }

    WorkerC = {
      subnet_id      = aws_subnet.workers["WorkerC"].id
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

  ## to decrese cost we use only one nat gateway otherwise should be three in each az

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
          gateway_id = aws_nat_gateway.nat["natGwA"].id
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
          gateway_id = aws_nat_gateway.nat["natGwA"].id
        }
      ]
      tags = {
        Name = "PrivateRouteC"
      }

    }
  }

}

