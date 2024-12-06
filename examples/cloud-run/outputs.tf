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

output "secret_names" {
  value       = module.secret-manager.secret_names
  description = "List of secret names."
}

output "secret_versions" {
  value       = module.secret-manager.secret_versions
  description = "List of secret versions."
}

output "kms_key_name" {
  value       = module.kms.keys[local.key_name]
  description = "KMS Key Name."
}

output "topic" {
  value       = google_pubsub_topic.secret_topic.id
  description = "Pub/Sub Topic associated to the Secret."
}

output "cloud-function-name" {
  value       = module.cloud-function.function_name
  description = "Cloud function name."
}

output "cloud-function-uri" {
  value       = module.cloud-function.function_uri
  description = "Cloud function URI."
}
