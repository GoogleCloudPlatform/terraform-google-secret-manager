/**
 * Copyright 2024 Google LLC
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
  description = "The project ID to manage the Secret Manager resources"
  type        = string
}

variable "name" {
  description = "The name of the secret to create."
  type        = string
}

variable "secret_data" {
  description = "The secret data. Must be no larger than 64KiB. Note: This property is sensitive and will not be displayed in the plan."
  type        = string
  sensitive   = true
}

variable "rotation" {
  description = "The rotation policy for the secret. If not set, the secret will not rotate."
  type = object({
    rotation_period    = string # The Duration between rotation notifications, in seconds.
    next_rotation_time = string # The time at which the Secret Manager secret is scheduled for rotation, in RFC3339 format. Examples: '2014-10-02T15:01:23Z' and '2014-10-02T15:01:23.045123456Z'
  })
  default = null
}

variable "user_managed_replication" {
  description = <<-EOT
    Replication parameters that will be used for the defined secret.
    If not provided, the secret will be automatically replicated using Google-managed key without any regional restrictions.
    Example:
      user_managed_replication = [
        {
          location = "us-central1"
          kms_key_name = "projects/PROJECT_ID/locations/LOCATION/keyRings/KEY_RING_NAME/cryptoKeys/KEY_NAME"
        },
        {
          location = "europe-west1"
          kms_key_name = "projects/PROJECT_ID/locations/LOCATION/keyRings/KEY_RING_NAME/cryptoKeys/KEY_NAME"
        }
      ]
  EOT
  type = list(object({
    location     = string,
    kms_key_name = string,
  }))
  default = []
}

variable "automatic_replication" {
  description = <<-EOT
    Automatic replication parameters that will be used for the defined secret.
    If not provided, automatic replication is enabled and Google-managed key is used by default.
    Example:
      automatic_replication = {
        kms_key_name = "projects/PROJECT_ID/locations/LOCATION/keyRings/KEY_RING_NAME/cryptoKeys/KEY_NAME"
      }
  EOT
  type = object({
    kms_key_name = optional(string, null)
  })
  default = {}
}

variable "topics" {
  type        = list(string)
  description = "A list of up to 10 Pub/Sub topics to which messages are published when control plane operations are called on the secret or its versions."
  default     = []
}

variable "labels" {
  type        = map(string)
  description = "The map of labels to be added to the defined secret."
  default     = {}
}
