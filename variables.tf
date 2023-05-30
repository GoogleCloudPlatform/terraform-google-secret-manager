/**
 * Copyright 2022 Google LLC
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
  type        = string
  description = "The project ID to manage the Secret Manager resources"
}

variable "secrets" {
  type = list(object({
    name                  = string
    next_rotation_time    = optional(string)
    rotation_period       = optional(string)
    automatic_replication = optional(bool)
    secret_data           = string
    iam_roles             = optional(map(list(string)))
  }))
  description = "The list of the secrets"
  default     = []
}

variable "user_managed_replication" {
  type        = map(list(object({ location = string, kms_key_name = string })))
  description = "Replication parameters that will be used for defined secrets"
  default     = {}
}

variable "topics" {
  type        = map(list(object({ name = string })))
  description = "topics that will be used for defined secrets"
  default     = {}
}

variable "labels" {
  type        = map(map(string))
  description = "labels to be added for the defined secrets"
  default     = {}
}

variable "add_kms_permissions" {
  type        = list(string)
  description = "The list of the crypto keys to give secret manager access to"
  default     = []
}

variable "add_pubsub_permissions" {
  type        = list(string)
  description = "The list of the pubsub topics to give secret manager access to"
  default     = []
}
