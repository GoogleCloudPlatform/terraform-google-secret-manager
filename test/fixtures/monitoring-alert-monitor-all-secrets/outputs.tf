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

output "secret_name" {
  value       = module.monitoring-alert-monitor-all-secrets.secret_name
  description = "The name of the created secret."
}

output "project_id" {
  value       = var.project_id
  description = "GCP Project ID where secret was created."
}

output "notification_channel_names" {
  value       = module.monitoring-alert-monitor-all-secrets.notification_channel_names
  description = "Notification channel names."
}
