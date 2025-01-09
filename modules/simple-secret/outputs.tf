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

output "id" {
  description = "The ID of the created secret"
  value       = google_secret_manager_secret.secret.id
}

output "name" {
  description = "The name of the created secret"
  value       = google_secret_manager_secret.secret.name
}

output "version" {
  description = "The version of the created secret"
  value       = google_secret_manager_secret_version.version.name
}

output "project_id" {
  description = "GCP Project ID where secret was created"
  value       = google_secret_manager_secret.secret.project
}

output "env_vars" {
  description = "Secret as environment variable"
  value       = { "SECRET" : { secret : var.name, version : local.secret_version } }
}
