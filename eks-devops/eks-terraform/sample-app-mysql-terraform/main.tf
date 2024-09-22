resource "kubernetes_namespace" "sample-mysql" {
  metadata {
    name = "sample-mysql"
  }
}


