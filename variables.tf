variable "template_file_directories" {
  description = "List of directories to search for template files."
  type        = list(string)
  default     = []
}
locals {
  template_file_directories = length(var.template_file_directories) == 0 ? [path.root] : var.template_file_directories
}

variable "template_file_suffix" {
  description = "Suffix extension for template files. Default is 'tftpl' for files ending in '.tftpl'"
  type        = string
  default     = "tftpl"
}

variable "enabled_template_file_types" {
  description = "Whether to load each template file type. All types default to `false`. NOTE: Enabling `tfvars` templates requires Terraform 1.8.1 or later."
  type = object({
    yaml   = optional(bool, false)
    json   = optional(bool, false)
    tfexpr = optional(bool, false)
    tfvars = optional(bool, false)
  })
  default = {}

  validation {
    condition     = anytrue(values(var.enabled_template_file_types))
    error_message = "At least one template file type must be enabled."
  }
}

variable "template_variables" {
  description = "A map of variables to be provided to each template file. Defaults to an empty map `{}`."
  type        = map(any)
  default     = {}
}

variable "group_key_prefixes" {
  description = "List of prefixes (eg. 'caf', 'azapi') used to group keys in the merged configuration map. Keys starting with '<prefix>_' are included in a separate grouped configuration, with the prefix removed from the key in the final output. This allows for logical separation and structured access to related configuration settings. Defaults to an empty list `[]`."
  type        = list(string)
  default     = []
}
