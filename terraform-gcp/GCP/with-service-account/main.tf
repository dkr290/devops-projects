resource "google_storage_bucket" "bucket-name" {
  
  name = var.bucket_name
  location = var.region
}