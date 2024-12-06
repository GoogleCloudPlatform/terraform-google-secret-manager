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

locals {
  key_name = "${var.key}-${random_id.random_topic_id_suffix.hex}"
}

resource "random_id" "random_topic_id_suffix" {
  byte_length = 2
}

resource "google_pubsub_topic" "secret_topic" {
  project = var.project_id
  name    = "topic-${random_id.random_topic_id_suffix.hex}"
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

resource "google_storage_bucket" "bucket" {
  project                     = var.project_id
  name                        = "${var.project_id}-pub-sub-source" # Every bucket name must be globally unique
  location                    = var.region
  uniform_bucket_level_access = true
}

data "archive_file" "src" {
  type        = "zip"
  source_dir  = "./cloudrun"
  output_path = "cloudrun.zip"
}

resource "google_storage_bucket_object" "object" {
  name   = "pub-sub-function-source.zip"
  bucket = google_storage_bucket.bucket.name
  source = data.archive_file.src.output_path # Add path to the zipped function source code
}

resource "google_service_account" "gcf_sa" {
  project      = var.project_id
  account_id   = "gcf-sa"
  display_name = "Test Service Account"
}

resource "google_project_iam_member" "gcf_invoker_role" {
  project = var.project_id
  role    = "roles/run.invoker"
  member  = "serviceAccount:${google_service_account.gcf_sa.email}"
}

module "cloud-function" {
  source  = "GoogleCloudPlatform/cloud-functions/google"
  version = "~> 0.6"

  function_name     = "secret-manager-pub-sub-consumer"
  project_id        = var.project_id
  function_location = var.region
  runtime           = "python312"
  entrypoint        = "subscribe"
  storage_source = {
    bucket = google_storage_bucket.bucket.name
    object = google_storage_bucket_object.object.name
  }

  event_trigger = {
    trigger_region        = var.region
    event_type            = "google.cloud.pubsub.topic.v1.messagePublished"
    pubsub_topic          = google_pubsub_topic.secret_topic.id
    retry_policy          = "RETRY_POLICY_RETRY"
    service_account_email = google_service_account.gcf_sa.email
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
    service_account_email            = google_service_account.gcf_sa.email
  }

  depends_on = [
    google_project_iam_member.gcf_invoker_role
  ]
}

module "kms" {
  source  = "terraform-google-modules/kms/google"
  version = "3.0.0"

  keyring              = "${var.keyring}-${random_id.random_topic_id_suffix.hex}"
  location             = var.region
  project_id           = var.project_id
  keys                 = [local.key_name]
  purpose              = "ENCRYPT_DECRYPT"
  key_protection_level = "HSM"
  prevent_destroy      = false
}

resource "google_kms_crypto_key_iam_member" "sm_sa_encrypter_decrypter" {
  role          = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
  member        = "serviceAccount:${google_project_service_identity.secretmanager_identity.email}"
  crypto_key_id = module.kms.keys[local.key_name]
}

module "secret-manager" {
  source  = "GoogleCloudPlatform/secret-manager/google"
  version = "~> 0.4"

  project_id = var.project_id
  secrets = [
    {
      name        = "secret-cloud-run-1"
      secret_data = "secret information"
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
