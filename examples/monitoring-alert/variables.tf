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
  type        = string
  description = "The project ID to manage the Secret Manager resources."
}

variable "email_addresses" {
  type        = list(string)
  description = "Email addresses used for sending notifications to."
}

variable "monitor_all_secrets" {
  type        = bool
  description = "Flag for determining if all secrets under the current project should be monitored. True for all secrets under the current project to be monitored, false for only the secret created in this example to be monitored. Default: false."
  default     = false
}
