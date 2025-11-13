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
  per_module_services = {
    simple-secret = [
      "secretmanager.googleapis.com",
      "pubsub.googleapis.com",
      "cloudkms.googleapis.com",
    ]
    root = [
      "secretmanager.googleapis.com",
      "iam.googleapis.com"
    ]
  }

  extra_services_for_tests = {
    root = [
      "cloudkms.googleapis.com",
      "pubsub.googleapis.com",
      "secretmanager.googleapis.com",
      "serviceusage.googleapis.com",
    ],
    simple-secret = [
      "cloudresourcemanager.googleapis.com",
      "monitoring.googleapis.com",
      "logging.googleapis.com"
    ],
  }
  per_module_test_services = {
    for module, services in local.per_module_services :
    module => setunion(services, lookup(local.extra_services_for_tests, module, []))
  }
}

module "project" {
  for_each = local.per_module_test_services

  source  = "terraform-google-modules/project-factory/google"
  version = "~> 17.0"

  name                     = "ci-secret-manager"
  random_project_id        = "true"
  random_project_id_length = 8
  org_id                   = var.org_id
  folder_id                = var.folder_id
  billing_account          = var.billing_account
  deletion_policy          = "DELETE"

  activate_apis = each.value
}
