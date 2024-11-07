## Requirements

No requirements.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| email\_addresses | Email addresses used for sending notifications to. | `list(string)` | n/a | yes |
| monitor\_all\_secrets | True for all secrets under the same project to be monitored, false for only the secret created in this example to be monitored. Default: false. | `bool` | `false` | no |
| project\_id | The project ID to manage the Secret Manager resources. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| notification\_channel\_names | Notification channel names. |
| project\_id | GCP Project ID where secret was created. |
| secret\_name | The name of the created secret. |
| secret\_version | The version of the created secret. |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
