
# --- Compute Engine SPOT GPU VM Instance ---

resource "google_compute_instance" "gpu_machine" {
  name         = "test-l4-spot-vm"
  machine_type = var.machine_type
  zone         = var.gcp_zone

  # ----------------------------------------------------
  # ⚠️ SPOT VM CONFIGURATION BLOCK ⚠️
  # ----------------------------------------------------
  scheduling {
    # 1. Enable the Spot provisioning model
    provisioning_model = "SPOT"

    # 2. Tell the VM what to do when Google preempts it (reclaims the resource)
    #    'TERMINATE' is the safest option—it shuts down gracefully.
    on_host_maintenance = "TERMINATE"

    # 3. Prevent the VM from automatically restarting after preemption
    automatic_restart = false

    # Optional: If you want to delete the VM automatically on preemption, use:
    # instance_termination_action = "DELETE"
    instance_termination_action = "STOP" # The default, stops the VM, preserving the disk.
  }
  # ----------------------------------------------------

  # Attach the NVIDIA L4 GPU (24GB VRAM)
  guest_accelerator {
    type  = "nvidia-l4"
    count = 1
  }

  # Use a Deep Learning VM Image with CUDA/Drivers pre-installed
  boot_disk {
    initialize_params {
      image = "projects/deeplearning-platform-release/global/images/family/common-cu121-ubuntu-2004-lts-nvidia-latest"
      size  = 100
      type  = "pd-ssd"
    }
  }

  # Network configuration
  network_interface {
    network = "default"
    access_config {
      # Leave empty to assign an ephemeral public IP
    }
  }

  # Service Account for VM
  service_account {
    # Replace with your VM's service account email, or use the default
    email  = "SERVICE_ACCOUNT_EMAIL" # e.g., <PROJECT_NUMBER>-compute@developer.gserviceaccount.com
    scopes = ["cloud-platform"]
  }
}

# --- Output the public IP to connect easily ---

output "external_ip" {
  value = google_compute_instance.gpu_machine.network_interface[0].access_config[0].nat_ip
}
