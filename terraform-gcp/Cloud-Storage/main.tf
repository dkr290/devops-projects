module "cloud-storage" {
  source = "../modules/cloud-storage"
  zone = var.zone
  region = var.region
  project_id = var.project_id
  bucket_name = var.bucket_name
  labels = var.labels
  uniform_bucket_level_access = var.uniform_bucket_level_access
  storage_class = var.storage_class
  bucket_object_name = var.bucket_object_name
  image_source = var.image_source
}