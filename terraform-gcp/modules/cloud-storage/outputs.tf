output "bucket_url" {
    value = google_storage_bucket.bucket-name[each.key].url
  
}