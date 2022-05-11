# terraform-google-secret-manager

This modules makes it easy to create Google Secret Manager secrets. If enabled it can enable the use of KMS keys for encrypting the secrets. Also if rotation is enabled and pubsub topics are passed in, then notification about secret rotation are sent to the pubsub topics. Here is a diagram of the resources that are deployed:

![arch_diagram](./assets/tf-secrets.png)

## Usage

Basic usage of this module is as follows:

```hcl
module "secret-manager" {
  source  = "terraform-google-modules/secret-manager/google"
  version = "~> 0.1"
  project_id = var.project_id
  secrets = [
    {
      name                     = "secret-1"
      automatic_replication    = true
      secret_data              = "secret information"
    },
  ]
}
```

Functional examples are included in the [examples](./examples/) directory.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_add_kms_permissions"></a> [add\_kms\_permissions](#input\_add\_kms\_permissions) | The list of the crypto keys to give secret manager access to | `list(string)` | `[]` | no |
| <a name="input_add_pubsub_permissions"></a> [add\_pubsub\_permissions](#input\_add\_pubsub\_permissions) | The list of the pubsub topics to give secret manager access to | `list(string)` | `[]` | no |
| <a name="input_labels"></a> [labels](#input\_labels) | labels to be added for the defined secrets | `map(map(string))` | `{}` | no |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | The project ID to manage the Secret Manager resources | `string` | n/a | yes |
| <a name="input_secrets"></a> [secrets](#input\_secrets) | The list of the secrets | `list(map(string))` | `[]` | no |
| <a name="input_topics"></a> [topics](#input\_topics) | topics that will be used for defined secrets | `map(list(object({ name = string })))` | `{}` | no |
| <a name="input_user_managed_replication"></a> [user\_managed\_replication](#input\_user\_managed\_replication) | Replication parameters that will be used for defined secrets | `map(list(object({ location = string, kms_key_name = string })))` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_secret_names"></a> [secret\_names](#output\_secret\_names) | The name list of Secrets |
| <a name="output_secret_versions"></a> [secret\_versions](#output\_secret\_versions) | The name list of Secret Versions |

## Requirements

These sections describe requirements for using this module.

### Software

The following dependencies must be available:

- [Terraform][terraform] v0.13
- [Terraform Provider for GCP][terraform-provider-gcp] plugin v3.0

### Service Account

A service account with the following roles must be used to provision
the resources of this module:

- Secret Manager Admin: `roles/secretmanager.admin`

If you want the module to change IAM permissions (for the pubsub and kms use cases), it will require the following additional roles:

- Project IAM Admin: `roles/resourcemanager.projectIamAdmin`

The [Project Factory module][project-factory-module] and the
[IAM module][iam-module] may be used in combination to provision a
service account with the necessary roles applied.

### APIs

A project with the following APIs enabled must be used to host the
resources of this module:

- Secret Manager API: `secretmanager.googleapis.com`

The [Project Factory module][project-factory-module] can be used to
provision a project with the necessary APIs enabled.

## Contributing

Refer to the [contribution guidelines](./CONTRIBUTING.md) for
information on contributing to this module.

[iam-module]: https://registry.terraform.io/modules/terraform-google-modules/iam/google
[project-factory-module]: https://registry.terraform.io/modules/terraform-google-modules/project-factory/google
[terraform-provider-gcp]: https://www.terraform.io/docs/providers/google/index.html
[terraform]: https://www.terraform.io/downloads.html

## Security Disclosures

Please see our [security disclosure process](./SECURITY.md).
