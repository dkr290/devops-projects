resource "random_string" "random_s" {

    length = var.id_length

  
}


resource "random_integer" "random_i" {

    min = var.min_int
    max= var.max_int
  
}