# Regional secret example

This example creates a regional secret in Google Cloud Secret Manager, with:

- A regional KMS key used for customer-managed encryption (CMEK) — co-located with the secret
- A Pub/Sub topic for rotation notifications, with the Secret Manager service identity granted `roles/pubsub.publisher`
- A `time_sleep` to wait for the Secret Manager service identity to propagate before granting it KMS access
- Authoritative IAM bindings on the secret for two distinct roles, demonstrating the `iam_bindings` map

## Note

If you manage any sensitive data with Terraform (database passwords, user passwords, private keys), treat the state itself as sensitive data. Storing state remotely can provide better security.

See: https://developer.hashicorp.com/terraform/language/state/sensitive-data

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| location | The location (region) of the Secret Manager resources. | `string` | `"us-central1"` | no |
| project\_id | The project ID to manage the Secret Manager resources. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| location | The location (region) of the regional secret. |
| secret\_id | The short secret\_id of the regional secret. |
| secret\_name | The fully-qualified name of the regional secret. |
| secret\_version | The fully-qualified name of the secret version. |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
