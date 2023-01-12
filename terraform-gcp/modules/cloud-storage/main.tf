resource "google_storage_bucket" "bucket-name" {
  
  name = var.bucket_name
  location = var.region
  uniform_bucket_level_access = var.uniform_bucket_level_access
  storage_class = var.storage_class

  labels = var.labels
   
  
}