data "terraform_remote_state" "example" {
  backend = "gcs"
  config = {
    bucket  = "terraformstate80"
    prefix  = "terraform/state"
  }
}
resource "template_file" "terraform" {
  template = "${greeting}"
  vars {
    greeting = "${data.terraform_remote_state.example.greeting}"
  }
}