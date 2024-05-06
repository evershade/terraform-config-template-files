terraform {
  required_version = ">= 1.3.0" # NOTE: Enabling `tfvars` templates requires Terraform 1.8.1 or later
  required_providers {
    terraform = {
      # Required for `.tfvars` templates
      source = "terraform.io/builtin/terraform"
    }
  }
}
