## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | 4.11.0 |
| <a name="provider_random"></a> [random](#provider\_random) | 3.1.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | The project ID to manage the Secret Manager resources | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_secret_names"></a> [secret\_names](#output\_secret\_names) | List of secret names |
| <a name="output_secret_versions"></a> [secret\_versions](#output\_secret\_versions) | List of secret versions |
