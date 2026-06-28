# Infra YAML Loader Integration

## Why

`terraform-terramate-cli` duplicated YAML discovery, shared-config merge,
workspace filtering, and linked-workspace auto-detection in `locals.tf`. That
logic now lives in `dasmeta/generic/renderer//modules/infra-yaml-loader`.

The Terramate driver should consume the shared submodule and keep only
Terramate stack generation in this repository.

## What

- call `infra-yaml-loader` from registry version `1.2.0`
- remove duplicated YAML locals from the driver root module
- ensure examples use unique `stack_id_prefix` values to avoid Terramate stack
  ID collisions across multiple example trees in one repository

## Acceptance Criteria

- driver root module uses `dasmeta/generic/renderer//modules/infra-yaml-loader`
- duplicated YAML merge/filter locals are removed from `locals.tf`
- examples assign unique `stack_id_prefix` values
- existing YAML examples continue to work without format changes
