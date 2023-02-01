resource "google_service_account" "svc-gke" {
  account_id = "svc-gke"
  project = var.project
  display_name = "Service Account GKE"

 
}

resource "google_project_iam_member" "project" {
  project = var.project
  role    = "roles/containerregistry.ServiceAgent"
  member  = "serviceAccount:${google_service_account.svc-gke.email}"
}