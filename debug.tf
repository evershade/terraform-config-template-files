locals {
  debug = false
}

/*
output "debug_template_file_directories" {
  description = "List of directories to search for template files."
  value       = local.template_file_directories

  # Ensure debugging is enabled - comment entire output when debugging is disabled
  precondition {
    condition     = local.debug
    error_message = "`local.debug` is set to `false`. Set `local.debug` to `true` or comment out the `debug_template_file_directories` output value."
  }
} /**/

/*
output debug_template_locals {
  description = "Mid-stage local values for templates"
  value = {
    yaml_filepaths     = local.yaml_filepaths
    yaml_files         = local.yaml_files
    json_filepaths     = local.json_filepaths
    json_files         = local.json_files
    tfexpr_filepaths   = local.tfexpr_filepaths
    tfexpr_files       = local.tfexpr_files
    tfvars_filepaths   = local.tfvars_filepaths
    tfvars_files       = local.tfvars_files
    all_files          = local.all_files
    unique_root_keys   = local.unique_root_keys
    key_instances_data = local.key_instances_data
  }

  # Ensure debugging is enabled - comment entire output when debugging is disabled
  precondition {
    condition     = local.debug
    error_message = "`local.debug` is set to `false`. Set `local.debug` to `true` or comment out the `debug_template_locals` output value."
  }
} /**/
