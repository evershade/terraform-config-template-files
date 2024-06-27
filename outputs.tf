output "all_configurations" {
  description = "Merged and validated configurations from all template files."
  value       = local.template_file_configurations
}

output "grouped_configurations" {
  description = "Grouped configurations from all template files, based on key prefixes."
  value       = local.grouped_template_file_configurations
}
