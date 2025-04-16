# Delayed destruction example

This test example creates a secret on Secret Manager,
with the delayed destruction feature activated.
With this feature, version destruction doesn't happen
immediately on calling destroy instead the version goes to a
disabled state and the actual destruction happens after this TTL expires.


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
| project\_id | The project ID to manage the Secret Manager resources | `string` | n/a | yes |
| version\_destroy\_ttl | Secret Version TTL after destruction request. | `string` | `"2592000s"` | no |

## Outputs

| Name | Description |
|------|-------------|
| secret\_names | List of secret names |
| secret\_versions | List of secret versions |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
