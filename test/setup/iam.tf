/**
 * Copyright 2019 Google LLC
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

locals {
  per_module_roles = {
    simple-secret = [
      "roles/secretmanager.admin",
      "roles/cloudkms.admin",
      "roles/pubsub.admin",
      "roles/logging.logWriter"
    ]
    root = [
      "roles/secretmanager.admin",
      "roles/iam.serviceAccountUser",
      "roles/logging.logWriter"
    ]
  }

  extra_roles_for_tests = {
    root = [
      "roles/cloudkms.admin",
      "roles/pubsub.admin",
    ],
    simple-secret = [
      "roles/logging.admin",
      "roles/monitoring.admin",
    ],
  }

  // A list of items like:
  // { module_name = "x", role = "role1"}
  // { module_name = "x", role = "role2"}
  // { module_name = "y", role = "role3"}
  module_role_combinations = flatten(
    [for module_name, _ in module.project :
      [for role in setunion(local.per_module_roles[module_name], lookup(local.extra_roles_for_tests, module_name, [])) : {
        module_name = module_name
        role        = role
        }
      ]
    ]
  )
}

resource "google_service_account" "int_test" {
  for_each = module.project

  project      = each.value.project_id
  account_id   = "ci-account"
  display_name = "ci-account"
}

resource "google_project_iam_member" "int_test" {
  for_each = {
    for combination in local.module_role_combinations :
    "${combination.module_name}.${combination.role}" => {
      service_account = google_service_account.int_test[combination.module_name]
      role            = combination.role
    }
  }

  project = each.value.service_account.project
  role    = each.value.role
  member  = "serviceAccount:${each.value.service_account.email}"
}

resource "google_service_account_key" "int_test" {
  for_each = module.project

  service_account_id = google_service_account.int_test[each.key].id
}

