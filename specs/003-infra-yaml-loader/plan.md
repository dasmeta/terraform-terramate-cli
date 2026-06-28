# Plan

1. Add `module "infra_yaml_loader"` to driver `main.tf` using registry source
   `dasmeta/generic/renderer//modules/infra-yaml-loader` `1.2.0`.
2. Replace duplicated YAML locals with `module.infra_yaml_loader` outputs.
3. Add unique `stack_id_prefix` to examples missing it.
4. Validate shared-config and linked-stack examples.

## Validation

- `terraform apply` and `meta validate` in `examples/with-shared-configs`
- Terramate stack generation and validate across example trees
