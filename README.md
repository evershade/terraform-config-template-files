# Template File Configuration Module for Terraform

This Terraform module is designed to manage and configure template files for your Terraform configuration. It provides a flexible way to handle different types of template files including `tfvars`, `yaml`, `json`, and `tfexpr`.

## Features

- Load template files from specified directories
- Convert template files to Terraform objects
- Merge all configuration data into a single map
- Group keys with prefixes
- Ensure keys are not overwritten by duplicates 

## Requirements

- Terraform 1.3.0 or later. Note: Enabling `tfvars` templates requires Terraform 1.8.1 or later.

## Inputs

- [`template_file_directories`](./variables.tf): List of directories to search for template files. Default is an empty list.
- [`template_file_suffix`](./variables.tf): Suffix extension for template files. Default is 'tftpl' for files ending in '.tftpl'.
- [`enabled_template_file_types`](./variables.tf): Whether to load each template file type. Note: Enabling `tfvars` templates requires Terraform 1.8.1 or later.
- [`group_key_prefixes`](./variables.tf): Prefixes for grouping keys.

## Outputs

- [`all_configurations`](./outputs.tf): A map of all the configuration data.
- [`grouped_configurations`](./outputs.tf): A map of grouped keys with prefixes.

## Usage

Define the module in your Terraform configuration file ([`main.tf`](./main.tf)):

```terraform
module "template_file_configuration" {
  source  = "app.terraform.io/my-module/template_file_configuration"
  version = "1.0.0"

  # set your variables here
}
```

### Grouping Keys with Prefixes

This module provides a feature to group keys based on their prefixes. This is particularly useful when you have a large number of keys and you want to categorize them for better organization and easier access.

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

```
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

Note that the prefix is removed from the key in the output, though the unchanged configuration will still be included in the `all_configurations` output. Also, keys that do not start with any of the specified prefixes are not included in the output.

This feature allows you to manage your configuration data in a more structured and organized manner.

## Contributing

Contributions to this module are welcome. Please ensure that you update the relevant documentation and tests when making changes.

## License

This module is licensed under the MIT License - see the LICENSE file for details.