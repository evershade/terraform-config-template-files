# Template File Configuration module for Terraform

This Terraform module is designed to manage and configure template files for your Terraform configuration. It provides a flexible way to handle different types of template files including `tfvars`, `yaml`, `json`, and `tfexpr`.

## Features

- Load template files from specified directories
- Support multiple template file types: YAML, JSON, Terraform expressions (tfexpr), and Terraform variables (tfvars)
- Convert template files to Terraform objects
- Merge configurations from multiple files into a single map
- Validate the merged configuration to ensure:
  - all instances of a key are mergeable
  - keys are not duplicated and overwritten
- Group keys with prefixes for structured access to related configuration settings

## Requirements

- Terraform 1.3.0 or later. Note: Enabling `tfvars` templates requires Terraform 1.8.1 or later.

## Inputs

- [`template_file_directories`](./variables.tf): List of directories to search for template files.
- [`template_file_suffix`](./variables.tf): Suffix extension for template files. Default is `"tftpl"` for files ending in ".tftpl".
- [`enabled_template_file_types`](./variables.tf): Whether to load each template file type. All types default to `false`. NOTE: Enabling `tfvars` templates requires Terraform 1.8.1 or later."
- [`template_variables`](./variables.tf): A map of variables to be provided to each template file for rendering dynamic variables inside the templates. Default is an empty map `{}`.
- [`group_key_prefixes`](./variables.tf): List of prefixes (eg. `"caf"`, `"azapi"`) used to group keys in the merged configuration map. Keys starting with `"<prefix>_"` are included in a separate grouped configuration. See details below at [`Grouping Keys with Prefixes`](#grouping-keys-with-prefixes). Default is an empty list `[]`.

## Outputs

- [`all_configurations`](./outputs.tf): The merged and validated configurations from all template files.
- [`grouped_configurations`](./outputs.tf): The grouped configurations from all template files, based on key prefixes. See details below at [`Grouping Keys with Prefixes`](#grouping-keys-with-prefixes).

## Usage

Define the module in your Terraform configuration file ([`main.tf`](./main.tf)):

```terraform
module "template_file_configuration" {
  source  = "app.terraform.io/my-module/template_file_configuration"
  version = "1.0.0"

  # set your variables here
  template_variables = {
    var1 = "value1"
    var2 = "value2"
  }
}
```

### Providing Template Variables

This feature allows you to provide a map of variables to the templates, which can be used to render dynamic variables inside the templates.

Here is an example of how you can define this variable:

```terraform
module "template_file_configuration" {
  source  = "app.terraform.io/my-module/template_file_configuration"
  version = "1.0.0"

  template_variables = {
    var1 = "value1"
    var2 = "value2"
  }
}
```

In this example, `var1` and `var2` will be available as variables inside the templates. For instance, if you have a template file with the following content:

```example.tfvars.tftpl
variable1 = "${var1}"
variable2 = "${var2}"
```

The rendered configuration will be:

```terraform
{
  ... other configurations

  variable1 = "value1"
  variable2 = "value2"

  ... other configurations
}
```

### Grouping Keys with Prefixes

This feature groups keys based on their prefixes. This allows for logical separation and structured access to related configuration settings.

Prefix grouping is particularly useful when you have a large number of keys and you want to categorize them for better organization and easier access.

The input for this feature is a list of prefixes that you want to use for grouping. This is provided through the [`group_key_prefixes`](./variables.tf) variable in your Terraform configuration file.

Here is an example of how you can define this variable:

```variables.tf
module "template_file_configuration" {
  source  = "app.terraform.io/my-module/template_file_configuration"
  version = "1.0.0"

  group_key_prefixes = ["app", "db"]
}
```

In this example, any keys that start with "app_" or "db_" will be grouped under "app" and "db" respectively in the output.

For instance, if your configuration data is as follows:

```variables.tf
{
  "app_name" = "myapp"
  "app_version" = "1.0.0"
  "db_name" = "mydb"
  "db_version" = "1.0.0"
  "other_key" = "value"
}
```

The output of [`grouped_configurations`](./outputs.tf) will be:

```terraform
{
  "app" = {
    "name" = "myapp"
    "version" = "1.0.0"
  }
  "db" = {
    "name" = "mydb"
    "version" = "1.0.0"
  }
}
```

Notes:

- Keys that do not start with any of the specified prefixes are not included in the `grouped_configurations` output.
- The prefix is removed from the key in the output, though the unchanged configuration will still be included in the `all_configurations` output.

## Contributing

Contributions to this module are welcome. Please ensure that you update the relevant documentation and tests when making changes.

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details.
