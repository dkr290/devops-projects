resource "kubernetes_persistent_volume_claim_v1" "pvc" {

  metadata {
    name = "ebs-mysql-pvc-claim"
  }

  spec {
    access_modes       = ["ReadWriteOnce"]
    storage_class_name = kubernetes_storage_class_v1.ebs-sc.metadata.0.name
    resources {
      requests = {
        storage = "5Gi"
      }
    }
  }
}
