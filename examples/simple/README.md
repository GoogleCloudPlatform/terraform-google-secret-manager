## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.13 |
| <a name="requirement_google"></a> [google](#requirement\_google) | ~> 4.0 |

## Providers

No providers.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| project\_id | The project ID to manage the Secret Manager resources | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| project\_id | GCP Project ID where secret was created |
| secret\_name | Secret Name |
| secret\_version | Secret Version |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
