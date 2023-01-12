output "result1" {
    value = local_file.example_resource.filename
}

output "result4" {
    value = random_shuffle.random_shuf.result
    
}