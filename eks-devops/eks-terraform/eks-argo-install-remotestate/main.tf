resource "kubernetes_namespace" "test" {
  metadata {
    name = "test"
  }
}
resource "kubernetes_namespace" "envoy" {
  metadata {
    name = "envoy-gateway-system"
  }
}
resource "kubernetes_namespace" "monitoring" {
  metadata {
    name = "monitoring"
  }
}
resource "helm_release" "argocd" {
  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  namespace  = "argocd"
  version    = "7.4.5" # Specify the desired chart version
  values = [
    "${file("argo-values.yaml")}"
  ]
  create_namespace = true

}
