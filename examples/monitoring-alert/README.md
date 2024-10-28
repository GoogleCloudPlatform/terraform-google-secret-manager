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
| notification\_channel\_name | Notification channel name. |
| project\_id | GCP Project ID where secret was created. |
| secret\_names | List of secret names. |
| secret\_versions | List of secret versions. |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
