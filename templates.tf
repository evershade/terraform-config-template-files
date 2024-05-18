locals {
  #region Load template files
  # Load yaml files from the specified template file directories and convert them to Terraform objects
  yaml_filepaths = var.enabled_template_file_types.yaml ? distinct(flatten([
    for dir in var.template_file_directories : fileset(dir, "*.{yml,yaml}.${var.template_file_suffix}")
  ])) : []
  yaml_files = { for filepath in local.yaml_filepaths : filepath => {
    tf   = yamldecode(templatefile(filepath, var.template_variables))
    raw  = file(filepath)
    type = "yaml"
    name = basename(filepath)
  } }

  # Load json files from the specified template file directories and convert them to Terraform objects
  json_filepaths = var.enabled_template_file_types.json ? distinct(flatten([
    for dir in var.template_file_directories : fileset(dir, "*.json.${var.template_file_suffix}")
  ])) : []
  json_files = { for filepath in local.json_filepaths : filepath => {
    tf   = jsondecode(templatefile(filepath, var.template_variables))
    raw  = file(filepath)
    type = "json"
    name = basename(filepath)
  } }

  # Load tfexpr files from the specified template file directories and convert them to Terraform objects
  tfexpr_filepaths = var.enabled_template_file_types.tfexpr ? distinct(flatten([
    for dir in var.template_file_directories : fileset(dir, "*.tfexpr.${var.template_file_suffix}")
  ])) : []
  tfexpr_files = { for filepath in local.tfexpr_filepaths : filepath => {
    tf   = templatefile(filepath, var.template_variables)
    raw  = file(filepath)
    type = "tfexpr"
    name = basename(filepath)
  } }

  # Load tfvars files from the specified template file directories and convert them to Terraform objects
  # NOTE: Enabling `tfvars` templates requires Terraform 1.8.1 or later
  tfvars_filepaths = var.enabled_template_file_types.tfvars ? distinct(flatten([
    for dir in var.template_file_directories : fileset(dir, "*.tfvars.${var.template_file_suffix}")
  ])) : []
  # NOTE: Call to `decode_tfvars` function moved to `tfvars_to_tf.tfexpr.tftpl` so the module doesn't break if Terraform version is less than 1.8.1
  tfvars_files = { for filepath in local.tfvars_filepaths : filepath => {
    tf   = templatefile("${path.module}/tfvars_to_tf.tfexpr.tftpl", {tfvars_file = templatefile(filepath, var.template_variables)})
    raw  = file(filepath)
    type = "tfvars"
    name = basename(filepath)
  } }
  #endregion

  #region Merge files
  # Merge all the files into a single map with filepath as the key
  all_files = merge(
    local.yaml_files,
    local.json_files,
    local.tfexpr_files,
    local.tfvars_files
  )

  # ```
  # all_files = {
  #   <filepath1> = {
  #     tf   = <parsed content>
  #     raw  = <raw string content>
  #     type = <file type>
  #     name = <file name>
  #   }
  #   <filepath2> = ...
  # }
  # ```
  #endregion Merge files

  #region Prepare for config merge
  # Extract unique root-level keys from `all_files`
  unique_root_keys = toset(flatten([
    for file in values(local.all_files) : keys(file.tf)
  ]))

  # Aggregate data about each root key instance across all files
  key_instances_data = { for root_key in local.unique_root_keys : root_key => [
    for filepath, file_data in local.all_files : {
      filepath  = filepath
      value     = file_data.tf[root_key]
      mergeable = can(keys(file_data.tf[root_key])) # Assume a value is mergeable if it has keys (i.e., it's a map/object).
      # TODO: Add a type field and determine the Terraform type of the value


    } if contains(keys(file_data.tf), root_key)
  ] }

  # ```
  # key_instances_data = {
  #   <root_key1> = [ # List of root_key1 instances data across all files
  #     {
  #       # Single instance data set of root_key1
  #       filepath  = <filepath1>
  #       value     = <local.all_files.filepath1.tf[root_key1]>
  #       mergeable = <true/false>
  #     },
  #     {
  #       filepath  = <filepath2>
  #       ...
  #     }
  #     ...
  #   ]
  # }
  # ```
  #endregion Prepare for config merge

  #region Debugging locals for `terraform console`
  debug_template_locals = {
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
  #endregion Debugging locals for `terraform console`
}

#region Validate & merge config
data "null_data_source" "validate_sources" {
  inputs = {}

  lifecycle {
    precondition {
      # Ensure all instances of a key are mergeable if the key appears in more than one file.
      condition = alltrue([
        for key, instances in local.key_instances_data :
        anytrue([
          length(instances) == 1,
          alltrue(instances[*].mergeable)
        ])
      ])
      error_message = join("", [
        "Root-level keys have non-mergeable values:\n",
        join("\n", flatten([
          for key, instances in local.key_instances_data : [
            for instance in instances :
            "- Key '${key}' from '${instance.filepath}'"
            if !instance.mergeable
          ]
          if length(instances) > 1
        ]))
      ])
    }

    precondition {
      # Check that, if a key is in more than one file, its sub-keys are not duplicated across the files, which would cause one sub-key to overwrite another.
      condition = alltrue([
        for key, instances in local.key_instances_data :
        alltrue([
          for all_keys in [flatten([for instance in instances : keys(instance.value) if instance.mergeable])] :
          length(distinct(all_keys)) == length(all_keys) # Check that all keys are unique
        ])
      ])
      error_message = join("", [
        "The following root-level keys have duplicate sub-keys in different configurations. Duplicated sub-keys will cause one to overwrite another:\n",
        join("\n", [
          for key, instances in local.key_instances_data :
          "- Key '${key}' in ${join(", ", formatlist("'%s'", instances[*].filepath))}"
          if length(distinct(flatten([for instance in instances : keys(instance.value)]))) != length(flatten([for instance in instances : keys(instance.value)]))
        ])
      ])
    }
  }
}
#endregion Validate config

locals {
  # TODO: move merging to a different module, to be called on the outputs of this module
  # Merge all the configuration data into a single map. Include validation data source to enforce wait.
  template_file_configurations = merge(
    data.null_data_source.validate_sources.outputs,
    {
      for key, instances in local.key_instances_data :
      key => length(instances) > 1 ? merge(instances[*].value...) : instances[0].value
    }
  )

  # Group keys with prefixes
  grouped_template_file_configurations = {
    for prefix in var.group_key_prefixes : prefix => {
      for key, value in local.template_file_configurations : trimprefix(key, "${prefix}_") => value
      if startswith(key, "${prefix}_")
    }
  }
}
