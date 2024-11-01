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

output "project_id" {
  value       = var.project_id
  description = "GCP Project ID where secret was created."
}

output "notification_channel_names" {
  value       = [for email_ch in google_monitoring_notification_channel.email_channel : email_ch.name]
  description = "Notification channel names."
}
