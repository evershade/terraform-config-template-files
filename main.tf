terraform {
  required_version = ">= 1.7.0" # TODO: Update to 1.8 after bugfix
  required_providers {
    terraform = {
      source = "terraform.io/builtin/terraform"
    }
  }
}
