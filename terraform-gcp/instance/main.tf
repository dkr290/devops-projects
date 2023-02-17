resource "google_compute_instance" "vm-from-tf" {
  for_each = toset(var.instances)
  name         = each.value
  machine_type = "e2-small"
  zone         = var.zone

  tags = ["terraform", "vm-instance"]

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
      size = 20
      labels = {
        environment = "development"
      }
    }
  }



  network_interface {
    network = "default"

    access_config {
      // Ephemeral public IP
    }
  }

  provisioner "local-exec" {
    command = "echo The instance IP address is ${self.self_link}"
    on_failure = continue
    
  }




 
}

resource "null_resource" "script" {
  triggers = {
    always_run = "${timestamp()}"
  }

  provisioner "local-exec" {
    command = "${path.module}/script.sh"
    interpreter = ["sh"]
  }
  
}

