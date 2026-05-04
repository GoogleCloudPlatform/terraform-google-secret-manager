# Terraform Google Regional Secret Manager Submodule

This module creates a single Google Cloud **regional** Secret Manager secret (using the `google_secret_manager_regional_secret*` resources, which target the regional API endpoint `secretmanager.<location>.rep.googleapis.com`). It supports CMEK, Pub/Sub topic notifications, rotation, version delayed-destruction, deletion protection, version aliases and authoritative IAM bindings indexed by role.

A regional secret is bound to a single GCP region and cannot be replicated, in contrast with the global secrets handled by the root module and the [`simple-secret`](../simple-secret/) submodule.

## Usage

Basic usage of this module is as follows:

```hcl
module "regional-secret" {
  source  = "GoogleCloudPlatform/secret-manager/google//modules/regional-secret"
  version = "~> 0.9"

  project_id  = var.project_id
  name        = "my-regional-secret"
  location    = "europe-west1"
  secret_data = "secret information"
}
```

With CMEK, Pub/Sub notifications, rotation, annotations and authoritative IAM:

```hcl
module "regional-secret" {
  source  = "GoogleCloudPlatform/secret-manager/google//modules/regional-secret"
  version = "~> 0.9"

  project_id  = var.project_id
  name        = "db-prod"
  location    = "europe-west1"
  secret_data = var.db_password

  annotations = {
    description = "Production database password"
    owner       = "platform-team"
  }

  customer_managed_encryption = {
    kms_key_name = google_kms_crypto_key.secret_key.id
  }

  topics = [google_pubsub_topic.secret_events.id]

  rotation = {
    next_rotation_time = "2030-01-01T00:00:00Z"
    rotation_period    = "31536000s"
  }

  iam_bindings = {
    "roles/secretmanager.secretAccessor" = [
      "group:sre@example.com",
      "serviceAccount:app@${var.project_id}.iam.gserviceaccount.com",
    ]
    "roles/secretmanager.viewer" = [
      "group:devs@example.com",
    ]
  }
}
```

A complete example that also provisions the KMS key and Pub/Sub topic is available in [`examples/regional-secret`](../../examples/regional-secret).

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| annotations | Free-form annotations on the secret (max 16KiB total). Useful for metadata such as a description, e.g. `{ description = "DB password (prod)" }`. | `map(string)` | `{}` | no |
| create\_version | Whether to create a secret version with `secret_data`. If false (or `secret_data` is null), no version is created. | `bool` | `true` | no |
| customer\_managed\_encryption | Customer-managed encryption configuration. The KMS key MUST be located in the same region as the secret.<br>Example:<br>  customer\_managed\_encryption = {<br>    kms\_key\_name = "projects/PROJECT\_ID/locations/LOCATION/keyRings/KEY\_RING/cryptoKeys/KEY"<br>  }<br>If null, Google-managed encryption is used. | <pre>object({<br>    kms_key_name = string<br>  })</pre> | `null` | no |
| deletion\_protection | If true, Terraform will refuse to destroy the secret. Must be disabled before a destroy can succeed. | `bool` | `false` | no |
| expire\_time | RFC3339 timestamp at which the secret is automatically deleted. Mutually exclusive with `ttl`. | `string` | `null` | no |
| iam\_bindings | Authoritative IAM bindings on the secret, indexed by role. Each role's full member list is set authoritatively (any member granted that role outside Terraform will be removed on apply).<br>Example:<br>  iam\_bindings = {<br>    "roles/secretmanager.secretAccessor" = ["group:sre@example.com", "user:dev1@example.com"]<br>    "roles/secretmanager.viewer"         = ["group:devs@example.com"]<br>  } | `map(list(string))` | `{}` | no |
| labels | The map of labels to be added to the secret. | `map(string)` | `{}` | no |
| location | The location (region) of the Secret Manager resources, e.g. "europe-west1". A regional secret is bound to a single region and cannot be replicated. | `string` | n/a | yes |
| name | The name (secret\_id) of the regional secret to create. | `string` | n/a | yes |
| project\_id | The project ID to manage the Secret Manager resources. | `string` | n/a | yes |
| rotation | Rotation policy for the secret. Notifications are published to `topics`. If null, the secret will not rotate. | <pre>object({<br>    next_rotation_time = optional(string)<br>    rotation_period    = optional(string)<br>  })</pre> | `null` | no |
| secret\_data | The secret data. Must be no larger than 64KiB. If null, no secret version is created (useful when the value is managed elsewhere). Note: this property is sensitive and will not be displayed in the plan. | `string` | `null` | no |
| topics | List of up to 10 Pub/Sub topic IDs to which messages are published when control plane operations are performed on the secret. The topics MUST exist before the secret is created and the Secret Manager service identity MUST have `roles/pubsub.publisher` on them. | `list(string)` | `[]` | no |
| ttl | Duration after which the secret is automatically deleted, e.g. "2592000s". Mutually exclusive with `expire_time`. | `string` | `null` | no |
| version\_aliases | Mapping from human-readable alias to version number, e.g. `{ "production" = "1" }`. | `map(string)` | `{}` | no |
| version\_destroy\_ttl | Secret version TTL after destruction request, e.g. "86400s". When set, destroyed versions transition to a disabled state and are actually destroyed after this TTL. Null disables this behavior. | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| env\_vars | Secret as environment variable, in the same shape as the simple-secret submodule. |
| id | The full resource ID of the regional secret. |
| location | The location (region) of the regional secret. |
| name | The fully-qualified name of the regional secret (projects/<project>/locations/<location>/secrets/<name>). |
| project\_id | GCP project ID where the regional secret was created. |
| secret\_id | The short secret\_id of the regional secret. |
| version | Fully-qualified name of the created secret version (or null if no version was created). |
| version\_id | Short version number of the created secret version (or null if no version was created). |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## Requirements

These sections describe requirements for using this module.

### Software

The following dependencies must be available:

- [Terraform][terraform] v1.3+
- [Terraform Provider for GCP][terraform-provider-gcp] plugin v5.10+ (regional Secret Manager resources are GA from this version)

### Service Account

A service account with the following roles must be used to provision the resources of this module:

- Secret Manager Admin: `roles/secretmanager.admin`

If the IAM bindings are managed by this module, the service account also needs:

- Secret Manager Admin (`roles/secretmanager.admin`) is sufficient to manage IAM on the secret.

If the secret uses CMEK or Pub/Sub topics, the **Secret Manager service identity** (`service-<project-number>@gcp-sa-secretmanager.iam.gserviceaccount.com`) must have:

- `roles/cloudkms.cryptoKeyEncrypterDecrypter` on the KMS key
- `roles/pubsub.publisher` on each Pub/Sub topic

These IAM grants are intentionally **not** managed by this module — they belong to the consumer or to a dedicated bootstrap module. See [`examples/regional-secret`](../../examples/regional-secret) for an end-to-end setup.

### APIs

A project with the following APIs enabled must be used to host the resources of this module:

- Secret Manager API: `secretmanager.googleapis.com`

The [Project Factory module][project-factory-module] can be used to provision a project with the necessary APIs enabled.

## IAM model

`iam_bindings` is **authoritative per role**. For each role passed in the map, this module manages the *entire* member list — any member granted that same role through another mechanism will be removed at the next `terraform apply`. Roles not listed in `iam_bindings` are left untouched.

If you need additive (non-authoritative) IAM, consider using `google_secret_manager_regional_secret_iam_member` resources outside this module on top of (or instead of) the `iam_bindings` provided here.

## Contributing

Refer to the [contribution guidelines](../../CONTRIBUTING.md) for information on contributing to this module.

[project-factory-module]: https://registry.terraform.io/modules/terraform-google-modules/project-factory/google
[terraform-provider-gcp]: https://www.terraform.io/docs/providers/google/index.html
[terraform]: https://www.terraform.io/downloads.html

## Security Disclosures

Please see our [security disclosure process](../../SECURITY.md).
