
resource "null_resource" "name" {

    depends_on = [
      module.ec2_public
    ]

connection {
    type     = "ssh"
    user     = "ec2-user"
    host     = aws_eip.bastion_eip.public_ip
    private_key = file("private_key/${var.private_key_file}")
  }

   provisioner "file" {
    source      = "private_key/${var.private_key_file}"
    destination = "/tmp/${var.private_key_file}"
  }
# remote provisioner , it is executing remote command
  provisioner "remote-exec" {
    inline = [
      "sudo chmod 400 /tmp/${var.private_key_file}"
    ]
  }
# Create time provisioner execute on apply
  provisioner "local-exec" {
    command = "echo VPC created on $(date) and PVC ID: ${module.vpc.vpc_id} >> creation-time-vpv.txt"
    working_dir = "local-exec-output-files/"
    on_failure = continue

  }
# will be executed during destroy time, this is destroy time provisioner
#   provisioner "local-exec" {
#     command = "echo VPC destroy on $(date)  >> destroy-time-vpc.txt"
#     working_dir = "local-exec-output-files/"
#     when = destroy

  
# }

}