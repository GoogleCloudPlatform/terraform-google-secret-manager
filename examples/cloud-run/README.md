This example creates a Secret monitored by a Cloud Run v2 Function.
The Cloud Function monitors [events](https://cloud.google.com/secret-manager/docs/event-notifications#events)
that can occur on a Secret Version. It can be used for executing actions when a
event happens, like sending warning emails or adding database entries when a Secret Version is destroyed.

## Requirements

If you manage any sensitive data with Terraform (like database passwords,
user passwords, or private keys), treat the state itself as sensitive data.
Storing state remotely can provide better security.

See more:
https://developer.hashicorp.com/terraform/language/state/sensitive-data

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| key | KMS Key name. | `string` | n/a | yes |
| keyring | KMS Keyring name. | `string` | n/a | yes |
| project\_id | The project ID to manage the Secret Manager resources. | `string` | n/a | yes |
| region | The region which the resources will be created at. | `string` | `"us-central1"` | no |

## Outputs

| Name | Description |
|------|-------------|
| cloud-function-name | Cloud function name. |
| cloud-function-uri | Cloud function URI. |
| kms\_key\_name | KMS Key Name. |
| secret\_names | List of secret names. |
| secret\_versions | List of secret versions. |
| topic | Pub/Sub Topic associated to the Secret. |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
