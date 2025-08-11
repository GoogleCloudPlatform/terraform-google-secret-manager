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

resource "random_id" "random_suffix" {
  byte_length = 2
}

resource "google_kms_key_ring" "key_ring" {
  name     = "key-ring-${random_id.random_suffix.hex}"
  location = var.location
  project  = var.project_id
}

resource "google_kms_crypto_key" "crypto_key" {
  name     = "crypto-key-${random_id.random_suffix.hex}s"
  key_ring = google_kms_key_ring.key_ring.id
}

resource "google_project_service_identity" "secretmanager_identity" {
  provider = google-beta
  project  = var.project_id
  service  = "secretmanager.googleapis.com"
}

resource "google_kms_crypto_key_iam_member" "sm_sa_encrypter_decrypter" {
  role          = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
  member        = "serviceAccount:${google_project_service_identity.secretmanager_identity.email}"
  crypto_key_id = google_kms_crypto_key.crypto_key.id
}

resource "google_pubsub_topic" "secret" {
  project = var.project_id
  name    = "topic-${random_id.random_suffix.hex}"
}

resource "google_pubsub_topic_iam_member" "sm_sa_publisher" {
  project = var.project_id
  role    = "roles/pubsub.publisher"
  member  = "serviceAccount:${google_project_service_identity.secretmanager_identity.email}"
  topic   = google_pubsub_topic.secret.name
}

module "secret-manager" {
  source = "../../modules/regional-secret"

  project_id = var.project_id
  secrets = [
    {
      name                        = "regional-secret-1"
      location                    = var.location
      secret_data                 = "secret information"
      next_rotation_time          = "2030-01-01T00:00:01Z"
      rotation_period             = "31536000s"
      customer_managed_encryption = google_kms_crypto_key.crypto_key.id
    },
  ]

  labels = {
    regional-secret-1 = {
      label = "my-label"
    }
  }

  topics = {
    regional-secret-1 = [
      {
        name = google_pubsub_topic.secret.id
      }
    ]
  }

  depends_on = [
    google_kms_crypto_key_iam_member.sm_sa_encrypter_decrypter,
    google_pubsub_topic_iam_member.sm_sa_publisher
  ]
}
