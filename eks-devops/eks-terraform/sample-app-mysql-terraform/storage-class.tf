resource "kubernetes_storage_class_v1" "ebs-sc" {

  metadata {
    name = "ebs-sc"
  }
  storage_provisioner    = "ebs.csi.aws.com"
  volume_binding_mode    = "WaitForFirstConsumer"
  allow_volume_expansion = "true"
  reclaim_policy         = "Retain" ## it will nt delete pv by deletion of application
  ## thie size can be increased but not decreased
}
