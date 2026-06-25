# Plan

1. Add `module "infra_yaml_fetched"` to driver `main.tf` using registry source
   `dasmeta/generic/renderer//modules/infra-yaml-fetched` `1.1.0`.
2. Replace duplicated YAML locals with `module.infra_yaml_fetched` outputs.
3. Add optional `yaml_files` / `auto_detected_linked_workspaces` inputs for
   nested local development.
4. Add unique `stack_id_prefix` to examples missing it.
5. Validate shared-config and linked-stack examples.

## Validation

- `terraform apply` and `meta validate` in `examples/with-shared-configs`
- Terramate stack generation and validate across example trees
