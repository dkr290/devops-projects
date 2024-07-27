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
    natEipC = {
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

}

