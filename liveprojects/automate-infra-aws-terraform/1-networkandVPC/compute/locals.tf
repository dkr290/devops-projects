locals {
  public_ec2_instaces = {

    publicSubnetA = var.publicSubnetA
    publicSubnetB = var.publicSubnetB
    publicSubnetC = var.publicSubnetC




  }
  private_app_ec2_instaces = {
    appSubnetA = var.appSubnetA
    appSubnetB = var.appSubnetB
    appSubnetC = var.appSubnetC
  }

}
