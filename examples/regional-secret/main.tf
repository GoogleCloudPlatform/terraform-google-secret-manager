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

resource "random_id" "random_suffix" {
  byte_length = 2
}

# --- KMS key (must live in the same region as the secret) -------------------

resource "google_kms_key_ring" "key_ring" {
  name     = "key-ring-${random_id.random_suffix.hex}"
  location = var.location
  project  = var.project_id
}

resource "google_kms_crypto_key" "crypto_key" {
  name     = "crypto-key-${random_id.random_suffix.hex}"
  key_ring = google_kms_key_ring.key_ring.id
}

# --- Secret Manager service identity ----------------------------------------

resource "google_project_service_identity" "secretmanager_identity" {
  provider = google-beta
  project  = var.project_id
  service  = "secretmanager.googleapis.com"
}

resource "time_sleep" "wait_service_identity_propagation" {
  depends_on      = [google_project_service_identity.secretmanager_identity]
  create_duration = "60s"
}

resource "google_kms_crypto_key_iam_member" "sm_sa_encrypter_decrypter" {
  role          = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
  member        = "serviceAccount:${google_project_service_identity.secretmanager_identity.email}"
  crypto_key_id = google_kms_crypto_key.crypto_key.id
  depends_on    = [time_sleep.wait_service_identity_propagation]
}

# --- Pub/Sub topic for rotation notifications -------------------------------

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

# --- Regional secret --------------------------------------------------------

module "regional-secret" {
  source = "../../modules/regional-secret"

  project_id  = var.project_id
  name        = "regional-secret-${random_id.random_suffix.hex}"
  location    = var.location
  secret_data = "secret information"

  labels = {
    label = "my-label"
  }

  annotations = {
    description = "Regional secret example with CMEK, rotation and granular IAM"
    owner       = "platform-team"
  }

  customer_managed_encryption = {
    kms_key_name = google_kms_crypto_key.crypto_key.id
  }

  topics = [google_pubsub_topic.secret.id]

  rotation = {
    next_rotation_time = "2030-01-01T00:00:01Z"
    rotation_period    = "31536000s"
  }

  iam_bindings = {
    "roles/secretmanager.secretAccessor" = [
      "serviceAccount:${google_project_service_identity.secretmanager_identity.email}",
    ]
    "roles/secretmanager.viewer" = [
      "serviceAccount:${google_project_service_identity.secretmanager_identity.email}",
    ]
  }

  depends_on = [
    google_kms_crypto_key_iam_member.sm_sa_encrypter_decrypter,
    google_pubsub_topic_iam_member.sm_sa_publisher,
  ]
}
