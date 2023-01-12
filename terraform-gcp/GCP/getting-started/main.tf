resource "google_storage_bucket" "bucket-from-username-pssword" {
  
  name = var.bucket_name
  location = var.location
}