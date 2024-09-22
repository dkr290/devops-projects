resource "kubernetes_service_v1" "mysql_svc" {
  metadata {
    name = "mysql-svc"
  }
  spec {
    selector = {
      app = kubernetes_deployment_v1.mysq_deployemnt.spec.0.selector.0.match_labels.app
    }
    port {
      port = 3306

    }


    type       = "ClusterIP"
    cluster_ip = "None" # this means it is going to user MySQL pod IP 
  }
}
