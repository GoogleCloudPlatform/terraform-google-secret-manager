## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.13 |
| <a name="requirement_google"></a> [google](#requirement\_google) | ~> 4.0 |

## Providers

No providers.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | The project ID to manage the Secret Manager resources | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_project_id"></a> [project\_id](#output\_project\_id) | n/a |
| <a name="output_project_number"></a> [project\_number](#output\_project\_number) | n/a |
| <a name="output_secret_names"></a> [secret\_names](#output\_secret\_names) | List of secret names |
| <a name="output_secret_versions"></a> [secret\_versions](#output\_secret\_versions) | List of secret versions |
