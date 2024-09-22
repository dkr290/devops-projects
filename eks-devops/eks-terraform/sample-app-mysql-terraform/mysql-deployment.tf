resource "kubernetes_deployment_v1" "mysq_deployemnt" {
  metadata {
    name = "simple-mysql-deployment"
    labels = {
      app = "mysql-app"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "mysql-app"
      }
    }
    strategy {
      type = "Recreate"
    }
    template {
      metadata {
        labels = {
          app = "mysql-app"
        }
      }

      spec {
        volume {
          name = "mysql-persistent-storage"
          persistent_volume_claim {
            claim_name = "ebs-mysql-pv-claim"
          }

        }
        volume {
          name = "dbcreation-script"
          config_map {
            name = "dbcreation-script"

          }

        }
        container {
          image = "mysql:5.6"
          name  = "mysql"

          resources {
            limits = {
              cpu    = "0.5"
              memory = "512Mi"
            }
            requests = {
              cpu    = "250m"
              memory = "50Mi"
            }
          }
          port {
            container_port = "3306"
            name           = "mysql"
          }
          env {
            name  = "MYSQL_ROOT_PASSWORD"
            value = "dbpassword1"
          }
          volume_mount {
            name       = "mysql-persistent-storage"
            mount_path = "/var/lib/mysql"
          }
          volume_mount {
            name       = "dbcreation-script"
            mount_path = "/docker-entrypoint-initdb.d"
          }
        }
      }
    }
  }
}
