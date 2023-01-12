output "result1" {
    value = random_integer.priority.result
}
output "result2" {
    value = random_integer.priority1.result
}

output "password1" {
    value = random_password.password1.result
    sensitive = true
}

output "result4" {
    value = random_shuffle.random_shuf.result
    
}