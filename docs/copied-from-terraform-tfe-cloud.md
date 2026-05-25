# Copied From terraform-tfe-cloud

Use this note to track:

- which logic was copied from `terraform-tfe-cloud`
- which logic was intentionally not copied
- what appears generic later versus Terraform Cloud-specific

## Initial Observation

The current minimum reusable behaviors appear to be:

- recursive YAML discovery
- exclusion of `_.yaml` from direct module generation
- prepend-style shared YAML merge behavior
- direct `source` and `version` gating for valid module entries

The current clearly Terraform Cloud-specific behaviors appear to include:

- TFC workspace creation
- TFC project and variable set wiring
- TFC execution settings and agent pool handling
- TFC-specific metadata in generated provider defaults

## Current POC Copy/Adaptation Status

### Reused Conceptually

- recursive YAML discovery using `fileset()`
- root `_.yaml` prepend behavior
- nested folder `_.yaml` prepend behavior pattern
- filtering out `_.yaml` from direct module generation
- gating valid module entries on `source` and `version`
- file generation with `local_file`

### Adapted For Terramate

- output path now targets a caller-provided Terramate stack directory instead of
  Terraform Cloud workspace directories
- generic Terraform files are now rendered through the shared
  `terraform-renderer-generic` module instead of being kept Terramate-local
- generated files now cover `stack.tm.hcl`, `main.tf`, `versions.tf`,
  `outputs.tf`, and `README.md`
- no Terraform Cloud resources are created
- no TFC remote state, project, workspace, OAuth, or variable set logic is included

### Reused Later

- linked workspace interpolation logic
- provider block generation
- output file generation
- backend generation with per-stack state identity

### Still Not Reused

- any Terraform Cloud-specific metadata or defaults
