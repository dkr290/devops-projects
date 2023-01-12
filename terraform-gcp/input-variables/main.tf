resource "local_file" "example_resource" {
  

  filename = var.file_name
  content = "Some text "
  file_permission = var.file_permission
}

resource "random_shuffle" "random_shuf" {
  input        = var.input_zones
  result_count = 2
}