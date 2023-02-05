resource "google_compute_instance" "vm-from-tf" {
  name         = "vm-from-tf"
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


#   provisioner "file" {
#     source = "app.conf"
#     destination = "/etc/app.conf"
#   }

#   provisioner "file" {

#     content = "url used:${self.self_link}"
#     destination = "/tmp/urlinstance.log"
    
#   }

#   provisioner "file" {
#       source = "conf"
#       destination="/etc"

#   }

# #copies all files and subfolders

#  provisioner "file" {
#   source = "conf/"
#   destination = "/tmp/conftest"
   
#  }
 # metadata_startup_script = "echo hi > /test.txt"

 
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

