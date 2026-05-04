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

/**********************************************************
  Regional Secret Manager Secret, Version and IAM bindings
 **********************************************************/

locals {
  secret_name_parts = split("/", try(google_secret_manager_regional_secret_version.version[0].name, ""))
  secret_version    = length(local.secret_name_parts) > 0 ? element(local.secret_name_parts, length(local.secret_name_parts) - 1) : ""
}

resource "google_secret_manager_regional_secret" "secret" {
  project   = var.project_id
  secret_id = var.name
  location  = var.location

  labels      = var.labels
  annotations = var.annotations

  dynamic "customer_managed_encryption" {
    for_each = var.customer_managed_encryption != null ? [var.customer_managed_encryption] : []
    content {
      kms_key_name = customer_managed_encryption.value.kms_key_name
    }
  }

  dynamic "topics" {
    for_each = var.topics
    content {
      name = topics.value
    }
  }

  dynamic "rotation" {
    for_each = var.rotation != null ? [var.rotation] : []
    content {
      next_rotation_time = rotation.value.next_rotation_time
      rotation_period    = rotation.value.rotation_period
    }
  }

  version_aliases     = var.version_aliases
  version_destroy_ttl = var.version_destroy_ttl
  expire_time         = var.expire_time
  ttl                 = var.ttl
  deletion_protection = var.deletion_protection
}

resource "google_secret_manager_regional_secret_version" "version" {
  count = var.create_version && var.secret_data != null ? 1 : 0

  secret      = google_secret_manager_regional_secret.secret.id
  secret_data = var.secret_data
}

resource "google_secret_manager_regional_secret_iam_binding" "bindings" {
  for_each = var.iam_bindings

  project   = var.project_id
  location  = var.location
  secret_id = google_secret_manager_regional_secret.secret.secret_id

  role    = each.key
  members = each.value
}
