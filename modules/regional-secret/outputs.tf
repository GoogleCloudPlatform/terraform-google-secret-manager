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

output "id" {
  description = "The full resource ID of the regional secret."
  value       = google_secret_manager_regional_secret.secret.id
}

output "name" {
  description = "The fully-qualified name of the regional secret (projects/<project>/locations/<location>/secrets/<name>)."
  value       = google_secret_manager_regional_secret.secret.name
}

output "secret_id" {
  description = "The short secret_id of the regional secret."
  value       = google_secret_manager_regional_secret.secret.secret_id
}

output "location" {
  description = "The location (region) of the regional secret."
  value       = google_secret_manager_regional_secret.secret.location
}

output "project_id" {
  description = "GCP project ID where the regional secret was created."
  value       = google_secret_manager_regional_secret.secret.project
}

output "version" {
  description = "Fully-qualified name of the created secret version (or null if no version was created)."
  value       = try(google_secret_manager_regional_secret_version.version[0].name, null)
}

output "version_id" {
  description = "Short version number of the created secret version (or null if no version was created)."
  value       = local.secret_version != "" ? local.secret_version : null
}

output "env_vars" {
  description = "Secret as environment variable, in the same shape as the simple-secret submodule."
  value       = { "SECRET" : { secret : var.name, version : local.secret_version } }
}
