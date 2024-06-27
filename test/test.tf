variable "template_vars" {
  description = "An object where keys represent variables to be provided to each template file."
  default = {}
}

module "config_files" {
  source = "../"

  template_file_suffix = "tftpl"
  group_key_prefixes   = ["test"]

  enabled_template_file_types = {
    yaml   = true
    json   = true
    tfexpr = true
    tfvars = true
  }

  template_variables = var.template_vars
}

output "all_configurations" {
  description = "Merged and validated configurations from all template files."
  value       = module.config_files.all_configurations
}

output "grouped_configurations" {
  description = "Grouped configurations from all template files, based on key prefixes."
  value       = module.config_files.grouped_configurations
}

