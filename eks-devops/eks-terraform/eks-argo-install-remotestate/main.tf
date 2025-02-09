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
  version    = "7.7.17" # Specify the desired chart version
  values = [
    "${file("argo-values.yaml")}"
  ]
  create_namespace = true

}

resource "kubernetes_ingress_v1" "alb_ingress" {
  count = var.enable_alb ? 1 : 0

  metadata {
    name      = "argocd-ingress"
    namespace = "argocd"
    annotations = {
      "kubernetes.io/ingress.class"                            = "alb"
      "alb.ingress.kubernetes.io/load-balancer-name"           = "argocd-ingress"
      "alb.ingress.kubernetes.io/scheme"                       = "internet-facing"
      "alb.ingress.kubernetes.io/healthcheck-path"             = "/healthz"
      "alb.ingress.kubernetes.io/healthcheck-protocol"         = "HTTP"
      "alb.ingress.kubernetes.io/healthcheck-port"             = "traffic-port"
      "alb.ingress.kubernetes.io/target-type"                  = "instance" ## needs argocd-server to be nodeport 
      "alb.ingress.kubernetes.io/healthcheck-interval-seconds" = "15"
      "alb.ingress.kubernetes.io/healthcheck-timeout-seconds"  = "5"
      "alb.ingress.kubernetes.io/success-codes"                = "200"
      "alb.ingress.kubernetes.io/healthy-threshold-count"      = "2"
      "alb.ingress.kubernetes.io/unhealthy-threshold-count"    = "2"
    }
  }

  spec {
    rule {
      http {
        path {
          path      = "/"
          path_type = "Prefix"
          backend {
            service {
              name = "argocd-server"
              port {
                number = 80

              }

            }

          }
        }
      }
    }

  }

}

