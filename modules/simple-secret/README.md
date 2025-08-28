# Terraform Google Secret Manager Secret Submodule

This module makes it easy to create a single Google Secret Manager secret. It supports using custom KMS keys (CMEK) for encrypting the secrets.
It also supports secret rotation and can configure the rotation notification to be sent to given pubsub topics.

## Usage

Basic usage of this module is as follows:

```hcl
module "secret-manager" {
  source  = "GoogleCloudPlatform/secret-manager/google//modules/simple-secret"
  version = "~> 0.9"

  project_id  = var.project_id
  name        = "secret-1"
  secret_data = "secret information"
}
```

Functional examples are included in the [examples](../examples/) directory:
- [examples/simple](../examples/simple)
- [examples/pubsub](../examples/pubsub)
- [examples/kms](../examples/kms)

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| automatic\_replication | Automatic replication parameters that will be used for the defined secret.<br>If not provided, automatic replication is enabled and Google-managed key is used by default.<br>Example:<br>  automatic\_replication = {<br>    kms\_key\_name = "projects/PROJECT\_ID/locations/LOCATION/keyRings/KEY\_RING\_NAME/cryptoKeys/KEY\_NAME"<br>  } | <pre>object({<br>    kms_key_name = optional(string, null)<br>  })</pre> | `{}` | no |
| labels | The map of labels to be added to the defined secret. | `map(string)` | `{}` | no |
| name | The name of the secret to create. | `string` | n/a | yes |
| project\_id | The project ID to manage the Secret Manager resources | `string` | n/a | yes |
| rotation | The rotation policy for the secret. If not set, the secret will not rotate. | <pre>object({<br>    rotation_period    = string # The Duration between rotation notifications, in seconds.<br>    next_rotation_time = string # The time at which the Secret Manager secret is scheduled for rotation, in RFC3339 format. Examples: '2014-10-02T15:01:23Z' and '2014-10-02T15:01:23.045123456Z'<br>  })</pre> | `null` | no |
| secret\_data | The secret data. Must be no larger than 64KiB. Note: This property is sensitive and will not be displayed in the plan. | `string` | n/a | yes |
| topics | A list of up to 10 Pub/Sub topics to which messages are published when control plane operations are called on the secret or its versions. | `list(string)` | `[]` | no |
| user\_managed\_replication | Replication parameters that will be used for the defined secret.<br>If not provided, the secret will be automatically replicated using Google-managed key without any regional restrictions.<br>Example:<br>  user\_managed\_replication = [<br>    {<br>      location = "us-central1"<br>      kms\_key\_name = "projects/PROJECT\_ID/locations/LOCATION/keyRings/KEY\_RING\_NAME/cryptoKeys/KEY\_NAME"<br>    },<br>    {<br>      location = "europe-west1"<br>      kms\_key\_name = "projects/PROJECT\_ID/locations/LOCATION/keyRings/KEY\_RING\_NAME/cryptoKeys/KEY\_NAME"<br>    }<br>  ] | <pre>list(object({<br>    location     = string,<br>    kms_key_name = string,<br>  }))</pre> | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| env\_vars | Secret as environment variable |
| id | The ID of the created secret |
| name | The name of the created secret |
| project\_id | GCP Project ID where secret was created |
| version | The version of the created secret |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## Requirements

These sections describe requirements for using this module.

### Software

The following dependencies must be available:

- [Terraform][terraform] v0.13
- [Terraform Provider for GCP][terraform-provider-gcp] plugin >=v4.83.0

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
