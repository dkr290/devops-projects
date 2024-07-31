locals {
  public_ec2_instaces = {

    publicSubnetA = {
      subnet_id = var.publicSubnetA
      bastionSG = var.BastionSG
      tags = {
        Name = "BastionHostA"
      }
    }
    publicSubnetB = {
      subnet_id = var.publicSubnetB
      bastionSG = var.BastionSG
      tags = {
        Name = "BastionHostB"
      }

    }
    publicSubnetC = {
      subnet_id = var.publicSubnetC
      bastionSG = var.BastionSG

      tags = {
        Name = "BastionHostC"
      }

    }




  }
}
