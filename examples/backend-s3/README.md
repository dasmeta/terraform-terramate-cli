# S3 Backend Example

This example is a runnable validation case for Terramate stacks backed by an
AWS S3 Terraform state backend.

It intentionally uses the Terramate driver default `linking_mode`, which is
`terramate_outputs_sharing`.

It also demonstrates the new mock-input controls:

- `group-0/module-b` disables Terramate mocks locally with `mock_inputs.enabled: false`
- `group-3/dns-records` keeps mocks enabled and provides custom fallback values with `mock_inputs.values`
- the root driver module also supports a global `mock_inputs_enabled` Terraform input, which acts as the default unless a stack YAML overrides it

This means the example intentionally contains both behaviors:

- `group-0/module-b` is a strict consumer and requires real applied outputs from `group-0/module-a`
- `group-3/dns-records` is a mock-tolerant consumer and can use custom fallback values when linked producer outputs are unavailable

It verifies that the root driver module:

- renders `backend "s3"` into each generated stack
- keeps one shared backend configuration at the module root
- automatically isolates the backend `key` per stack path
- reuses shared YAML config from the example-root `_.yaml`
- auto-detects the linked stack dependency from interpolation
- renders grouped stacks where `group-1/module-c` consumes outputs from both `group-0/module-a` and `group-0/module-b`
- creates a real Route53 hosted zone `terramate-test.devops.dasmeta.com` in `group-2/dns-zone`
- creates aggregate TXT records in `group-3/dns-records` using linked outputs from `group-0/module-a`, `group-0/module-b`, and `group-1/module-c`
- propagates sensitivity into Terramate outputs-sharing only when both the producer has `output.sensitive: true` and the consumer marks the linked variable with `variable_options.<name>.sensitive: true`
- supports configurable Terramate mock inputs, including stack-local disablement and custom fallback values
- keeps linked stack support compatible with backend-aware remote state wiring

The values in this example are safe placeholders intended to show the generated
configuration shape. Replace them with real backend settings before using the
generated stacks against a live S3 bucket.

This example intentionally creates real AWS Route53 resources:

- hosted zone: `terramate-test.devops.dasmeta.com`
- TXT records:
  - `module-a.terramate-test.devops.dasmeta.com`
  - `module-b.terramate-test.devops.dasmeta.com`
  - `module-c.terramate-test.devops.dasmeta.com`

For plain example validation:

- `terraform init`
- `terraform apply`

No AWS credentials are required for that step because the example only renders
files and checks their content.

To try the generated stacks against a real S3 backend, override the non-secret
settings as needed:

```bash
export TF_VAR_backend_s3_bucket="my-real-state-bucket"
export TF_VAR_backend_s3_region="eu-central-1"
export TF_VAR_backend_s3_key_prefix="terramate"
```

Then provide AWS credentials using the normal AWS environment variables before
running commands inside `_terraform/`, for example:

```bash
export AWS_ACCESS_KEY_ID="..."
export AWS_SECRET_ACCESS_KEY="..."
export AWS_DEFAULT_REGION="$TF_VAR_backend_s3_region"
```

When `linking_mode = "terramate_outputs_sharing"` is used, there are two
separate Terramate requirements:

1. The Terramate experiment must be enabled once at the real repository root:

```hcl
terramate {
  config {
    experiments = ["outputs-sharing"]
  }
}
```

2. The generated example writes `_terraform/terramate.tm.hcl` with the required
`sharing_backend "default"` block for the generated stack tree.

Terramate only accepts the `experiments` setting at the real repository root.

Recommended command flow:

1. Generate or refresh the Terramate example output:

```bash
cd examples/backend-s3
terraform init
terraform apply
```

Why:

- `terraform init` installs the providers and module dependencies for the example
- `terraform apply` renders or refreshes the generated Terramate stacks under `_terraform/`

2. Generate Terramate outputs-sharing helper code:

```bash
terramate -C _terraform generate
```

Why:

- outputs-sharing uses the generated `_terraform/terramate.tm.hcl` sharing backend
- Terramate generates helper Terraform code like `terramate-outputs.tf`
- Terramate will refuse `run` if this generated code is outdated

3. Initialize Terraform in the generated Terramate stacks:

```bash
terramate -C _terraform run \
  --disable-safeguards=git-untracked,git-uncommitted \
  -- terraform init
```

Why:

- generated stacks still need a real Terraform init after Terramate has generated the outputs-sharing helper code
- `terraform init` does not require outputs-sharing values
- some consumer stacks in this example intentionally disable mocks, so enabling sharing during init can fail before any real producer outputs exist
- this step initializes each stack backend, providers, and modules before planning or applying

4. Run a cross-stack Terramate plan with outputs sharing enabled:

```bash
terramate -C _terraform run \
  --enable-sharing \
  --mock-on-fail \
  --disable-safeguards=git-untracked,git-uncommitted \
  -- terraform plan
```

Why:

- `--enable-sharing` activates Terramate outputs-sharing
- `--mock-on-fail` allows mock-tolerant consumers to plan even when producer outputs are not yet applied
- stacks that explicitly set `mock_inputs.enabled: false` still require real producer outputs, even if `--mock-on-fail` is present
- `--disable-safeguards=git-untracked,git-uncommitted` is useful for local development because generated files and working tree changes would otherwise block `run`

If you are starting from scratch and a strict consumer stack fails to plan because
its producer outputs are not applied yet, run apply instead of plan so Terramate
can create the producer stacks first:

```bash
terramate -C _terraform run \
  --enable-sharing \
  --mock-on-fail \
  --disable-safeguards=git-untracked,git-uncommitted \
  -- terraform apply -auto-approve
```

5. Apply through Terramate when you are ready:

```bash
terramate -C _terraform run \
  --enable-sharing \
  --mock-on-fail \
  --disable-safeguards=git-untracked,git-uncommitted \
  -- terraform apply -auto-approve
```

6. Verify the Route53 zone and records with AWS CLI:

```bash
aws route53 list-hosted-zones-by-name \
  --dns-name terramate-test.devops.dasmeta.com

aws route53 list-resource-record-sets \
  --hosted-zone-id YOUR_ZONE_ID
```

Why:

- the first command confirms the hosted zone exists
- the second command lets you verify the TXT records created from linked stack outputs

Optional debugging commands:

List the generated Terramate stacks:

```bash
terramate -C _terraform list
```

Run plain Terraform inside one generated stack:

```bash
cd _terraform/group-0/module-a
terraform init -input=false
terraform plan
```

Cleanup when finished:

1. Destroy through Terramate:

```bash
terramate -C _terraform run \
  --reverse \
  --enable-sharing \
  --disable-safeguards=git-untracked,git-uncommitted \
  -- terraform destroy -auto-approve
```

Why:

- normal Terramate execution order follows dependency creation order
- destroy must run in reverse so `group-3/dns-records` removes Route53 records before `group-2/dns-zone` tries to delete the hosted zone
- `--mock-on-fail` should be omitted for destroy in this example because Route53 record arguments cannot tolerate null mock values

2. Confirm the hosted zone and records are gone:

```bash
aws route53 list-hosted-zones-by-name \
  --dns-name terramate-test.devops.dasmeta.com
```
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.3 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_local"></a> [local](#provider\_local) | 2.9.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_this"></a> [this](#module\_this) | ../.. | n/a |

## Resources

| Name | Type |
|------|------|
| [local_file.dns_records_main_tf](https://registry.terraform.io/providers/hashicorp/local/latest/docs/data-sources/file) | data source |
| [local_file.dns_records_sharing_tm_hcl](https://registry.terraform.io/providers/hashicorp/local/latest/docs/data-sources/file) | data source |
| [local_file.dns_records_stack_tm_hcl](https://registry.terraform.io/providers/hashicorp/local/latest/docs/data-sources/file) | data source |
| [local_file.dns_records_versions_tf](https://registry.terraform.io/providers/hashicorp/local/latest/docs/data-sources/file) | data source |
| [local_file.dns_zone_main_tf](https://registry.terraform.io/providers/hashicorp/local/latest/docs/data-sources/file) | data source |
| [local_file.dns_zone_versions_tf](https://registry.terraform.io/providers/hashicorp/local/latest/docs/data-sources/file) | data source |
| [local_file.module_a_sharing_tm_hcl](https://registry.terraform.io/providers/hashicorp/local/latest/docs/data-sources/file) | data source |
| [local_file.module_a_versions_tf](https://registry.terraform.io/providers/hashicorp/local/latest/docs/data-sources/file) | data source |
| [local_file.module_b_main_tf](https://registry.terraform.io/providers/hashicorp/local/latest/docs/data-sources/file) | data source |
| [local_file.module_b_sharing_tm_hcl](https://registry.terraform.io/providers/hashicorp/local/latest/docs/data-sources/file) | data source |
| [local_file.module_b_stack_tm_hcl](https://registry.terraform.io/providers/hashicorp/local/latest/docs/data-sources/file) | data source |
| [local_file.module_b_versions_tf](https://registry.terraform.io/providers/hashicorp/local/latest/docs/data-sources/file) | data source |
| [local_file.module_c_main_tf](https://registry.terraform.io/providers/hashicorp/local/latest/docs/data-sources/file) | data source |
| [local_file.module_c_sharing_tm_hcl](https://registry.terraform.io/providers/hashicorp/local/latest/docs/data-sources/file) | data source |
| [local_file.module_c_stack_tm_hcl](https://registry.terraform.io/providers/hashicorp/local/latest/docs/data-sources/file) | data source |
| [local_file.module_c_versions_tf](https://registry.terraform.io/providers/hashicorp/local/latest/docs/data-sources/file) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_backend_s3_bucket"></a> [backend\_s3\_bucket](#input\_backend\_s3\_bucket) | S3 bucket name used by the generated backend example. | `string` | `"example-terraform-state"` | no |
| <a name="input_backend_s3_key_prefix"></a> [backend\_s3\_key\_prefix](#input\_backend\_s3\_key\_prefix) | S3 key prefix that the Terramate driver extends per stack. | `string` | `"terramate"` | no |
| <a name="input_backend_s3_region"></a> [backend\_s3\_region](#input\_backend\_s3\_region) | AWS region used by the generated S3 backend example. | `string` | `"eu-central-1"` | no |

## Outputs

No outputs.
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
