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

output "secret_id" {
  value       = module.regional-secret.secret_id
  description = "The short secret_id of the regional secret."
}

output "secret_name" {
  value       = module.regional-secret.name
  description = "The fully-qualified name of the regional secret."
}

output "secret_version" {
  value       = module.regional-secret.version
  description = "The fully-qualified name of the secret version."
}

output "location" {
  value       = module.regional-secret.location
  description = "The location (region) of the regional secret."
}
