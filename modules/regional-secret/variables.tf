/**
 * Copyright 2026 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

variable "project_id" {
  description = "The project ID to manage the Secret Manager resources."
  type        = string
}

variable "name" {
  description = "The name (secret_id) of the regional secret to create."
  type        = string
}

variable "location" {
  description = "The location (region) of the Secret Manager resources, e.g. \"europe-west1\". A regional secret is bound to a single region and cannot be replicated."
  type        = string
}

variable "secret_data" {
  description = "The secret data. Must be no larger than 64KiB. If null, no secret version is created (useful when the value is managed elsewhere). Note: this property is sensitive and will not be displayed in the plan."
  type        = string
  sensitive   = true
  default     = null
}

variable "create_version" {
  description = "Whether to create a secret version with `secret_data`. If false (or `secret_data` is null), no version is created."
  type        = bool
  default     = true
}

variable "labels" {
  description = "The map of labels to be added to the secret."
  type        = map(string)
  default     = {}
}

variable "annotations" {
  description = "Free-form annotations on the secret (max 16KiB total). Useful for metadata such as a description, e.g. `{ description = \"DB password (prod)\" }`."
  type        = map(string)
  default     = {}
}

variable "customer_managed_encryption" {
  description = <<-EOT
    Customer-managed encryption configuration. The KMS key MUST be located in the same region as the secret.
    Example:
      customer_managed_encryption = {
        kms_key_name = "projects/PROJECT_ID/locations/LOCATION/keyRings/KEY_RING/cryptoKeys/KEY"
      }
    If null, Google-managed encryption is used.
  EOT
  type = object({
    kms_key_name = string
  })
  default = null
}

variable "topics" {
  description = "List of up to 10 Pub/Sub topic IDs to which messages are published when control plane operations are performed on the secret. The topics MUST exist before the secret is created and the Secret Manager service identity MUST have `roles/pubsub.publisher` on them."
  type        = list(string)
  default     = []
}

variable "rotation" {
  description = "Rotation policy for the secret. Notifications are published to `topics`. If null, the secret will not rotate."
  type = object({
    next_rotation_time = optional(string)
    rotation_period    = optional(string)
  })
  default = null
}

variable "version_aliases" {
  description = "Mapping from human-readable alias to version number, e.g. `{ \"production\" = \"1\" }`."
  type        = map(string)
  default     = {}
}

variable "version_destroy_ttl" {
  description = "Secret version TTL after destruction request, e.g. \"86400s\". When set, destroyed versions transition to a disabled state and are actually destroyed after this TTL. Null disables this behavior."
  type        = string
  default     = null
}

variable "expire_time" {
  description = "RFC3339 timestamp at which the secret is automatically deleted. Mutually exclusive with `ttl`."
  type        = string
  default     = null
}

variable "ttl" {
  description = "Duration after which the secret is automatically deleted, e.g. \"2592000s\". Mutually exclusive with `expire_time`."
  type        = string
  default     = null
}

variable "deletion_protection" {
  description = "If true, Terraform will refuse to destroy the secret. Must be disabled before a destroy can succeed."
  type        = bool
  default     = false
}

variable "iam_bindings" {
  description = <<-EOT
    Authoritative IAM bindings on the secret, indexed by role. Each role's full member list is set authoritatively (any member granted that role outside Terraform will be removed on apply).
    Example:
      iam_bindings = {
        "roles/secretmanager.secretAccessor" = ["group:sre@example.com", "user:dev1@example.com"]
        "roles/secretmanager.viewer"         = ["group:devs@example.com"]
      }
  EOT
  type        = map(list(string))
  default     = {}
}
