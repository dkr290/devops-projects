resource "google_storage_bucket" "bucket-name" {

  name = var.bucket_names
  location = var.region
  uniform_bucket_level_access = var.uniform_bucket_level_access
  storage_class = var.storage_class

  lifecycle_rule {
    condition  {
          age = var.age
    }
      
    
    action {
      type = "SetStorageClass"
      storage_class = var.type
    }
  }

  labels = var.labels
   
  
}

resource "google_storage_bucket_object" "sample-object" {
  name   = var.bucket_object_name
  bucket = google_storage_bucket.bucket-name.name
  source = var.image_source
}

resource "google_storage_object_access_control" "public_rule" {
  object = google_storage_bucket_object.sample-object.name
  bucket = google_storage_bucket.bucket-name.name
  role   = "READER"
  entity = "allUsers"
}
