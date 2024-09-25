# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/), and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.1] - 2024-09-25

### Changed

- Updated tests to confirm duplicate root key values with differing objects merge properly

### Fixed
- Fix issue in merge of configs for duplicate root keys with differing object value structures

## [0.1.0] - 2024-06-26

### Added
- Initial release of the module
- Support for loading template files from specified directories
- Conversion of template files to Terraform objects
- Merge of all configuration data into a single map
- Map variable for each template file to render dynamic variables
- Group keys with prefixes
- Validate configuration and provide error messages
  - Check that all duplicated root keyes are mergeable
  - Check that no child keys are duplicated as collisions would be silently overwritten during merge of root keys
