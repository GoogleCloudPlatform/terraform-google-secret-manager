# Monitoring Alerting Secret

This test example creates a secret on Secret Manager,
monitors it and send notifications via email when a secret version is destroyed.
Has a notification rate limit of 5 minutes i.e. if two secrets are deleted
in less than 5 minutes only one notification will be sent.

## Requirements

No requirements.

## Note

If you manage any sensitive data with Terraform (like database passwords,
user passwords, or private keys), treat the state itself as sensitive data.
Storing state remotely can provide better security.

See more:
https://developer.hashicorp.com/terraform/language/state/sensitive-data

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| email\_addresses | Email addresses used for sending notifications to. | `list(string)` | n/a | yes |
| monitor\_all\_secrets | Flag for determining if all secrets under the current project should be monitored. True for all secrets under the current project to be monitored, false for only the secret created in this example to be monitored. Default: false. | `bool` | `false` | no |
| project\_id | The project ID to manage the Secret Manager resources. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| notification\_channel\_names | Notification channel names. |
| project\_id | GCP Project ID where secret was created. |
| secret\_name | The name of the created secret. |
| secret\_version | The version of the created secret. |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
