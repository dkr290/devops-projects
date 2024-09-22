resource "kubernetes_config_map_v1" "sample_configmap" {
  metadata {
    name = "dbcreation-script"
  }

  data = {
    "mysql_sample.sql" = "${file("${path.module}/mysqlcf.sql")}"

  }

}















