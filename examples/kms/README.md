## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | 4.11.0 |
| <a name="provider_google-beta"></a> [google-beta](#provider\_google-beta) | 4.11.0 |
| <a name="provider_random"></a> [random](#provider\_random) | 3.1.0 |

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| project\_id | The project ID to manage the Secret Manager resources | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| secret\_names | List of secret names |
| secret\_versions | List of secret versions |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
