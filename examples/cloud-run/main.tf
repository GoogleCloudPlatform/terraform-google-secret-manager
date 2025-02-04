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

resource "random_id" "random_topic_id_suffix" {
  byte_length = 2
}

resource "random_string" "suffix" {
  length  = 4
  upper   = false
  special = false
}

resource "google_pubsub_topic" "secret_topic" {
  project = var.project_id
  name    = "topic-${random_string.suffix.result}"
}

resource "google_project_service_identity" "secretmanager_identity" {
  provider = google-beta
  project  = var.project_id
  service  = "secretmanager.googleapis.com"
}

resource "google_pubsub_topic_iam_member" "sm_sa_publisher" {
  project = var.project_id
  role    = "roles/pubsub.publisher"
  member  = "serviceAccount:${google_project_service_identity.secretmanager_identity.email}"
  topic   = google_pubsub_topic.secret_topic.name
}

resource "google_storage_bucket" "cloudrun_sourcecode" {
  project                     = var.project_id
  name                        = "${var.project_id}-secret-function-source-${random_string.suffix.result}" # Every bucket name must be globally unique
  location                    = var.region
  uniform_bucket_level_access = true
}

data "archive_file" "compressed_cloudrun_sourcecode" {
  type        = "zip"
  source_dir  = "./cloudrun-source-code"
  output_path = "cloudrun-source-code.zip"
}

resource "google_storage_bucket_object" "cloudrun_sourcecode" {
  name   = "pub-sub-function-source.zip"
  bucket = google_storage_bucket.cloudrun_sourcecode.name
  source = data.archive_file.compressed_cloudrun_sourcecode.output_path # Add path to the zipped function source code
}

resource "google_service_account" "cloud_function_sa" {
  project      = var.project_id
  account_id   = "gcf-sa"
  display_name = "Test Service Account"
}

resource "google_project_iam_member" "gcf_invoker_role" {
  project = var.project_id
  role    = "roles/run.invoker"
  member  = "serviceAccount:${google_service_account.cloud_function_sa.email}"
}

module "cloud_function" {
  source  = "GoogleCloudPlatform/cloud-functions/google"
  version = "~> 0.6"

  function_name     = "secret-manager-pub-sub-consumer"
  project_id        = var.project_id
  function_location = var.region
  runtime           = "python312"
  entrypoint        = "subscribe"
  storage_source = {
    bucket = google_storage_bucket.cloudrun_sourcecode.name
    object = google_storage_bucket_object.cloudrun_sourcecode.name
  }

  event_trigger = {
    trigger_region        = var.region
    event_type            = "google.cloud.pubsub.topic.v1.messagePublished"
    pubsub_topic          = google_pubsub_topic.secret_topic.id
    retry_policy          = "RETRY_POLICY_RETRY"
    service_account_email = google_service_account.cloud_function_sa.email
  }

  service_config = {
    max_instance_count               = 1
    min_instance_count               = 1
    available_memory                 = "256M"
    timeout_seconds                  = 60
    max_instance_request_concurrency = 80
    available_cpu                    = "1"
    ingress_settings                 = "ALLOW_INTERNAL_ONLY"
    all_traffic_on_latest_revision   = true
    service_account_email            = google_service_account.cloud_function_sa.email
  }

  depends_on = [
    google_project_iam_member.gcf_invoker_role
  ]
}

module "secret_manager" {
  source  = "GoogleCloudPlatform/secret-manager/google"
  version = "~> 0.5.0"

  project_id = var.project_id
  secrets = [
    {
      name        = "secret-cloud-run-1"
      secret_data = "secret information (SENSITIVE TEXT)"
    },
  ]
  topics = {
    secret-cloud-run-1 = [
      {
        name = google_pubsub_topic.secret_topic.id
      }
    ]
  }
  user_managed_replication = {
    secret-cloud-run-1 = [
      {
        location     = var.region
        kms_key_name = module.kms.keys[local.key_name]
      },
    ]
  }
  depends_on = [
    google_pubsub_topic_iam_member.sm_sa_publisher,
    google_kms_crypto_key_iam_member.sm_sa_encrypter_decrypter
  ]
}
