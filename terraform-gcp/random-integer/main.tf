resource "random_integer" "priority" {
  
  min = 1
  max = 50000
}
resource "random_integer" "priority1" {
  
  min = 1
  max = 50000
}

resource "random_password" "password1" {
  length = 12
  special = true
  
}

resource "random_shuffle" "random_shuf" {
  input        = ["us-west-1a", "us-west-1c", "us-west-1d", "us-west-1e"]
  result_count = 2
}