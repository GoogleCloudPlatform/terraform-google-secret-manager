/**
 * Copyright 2022 Google LLC
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
  region = "us-central1"
}
resource "random_id" "random_kms_suffix" {
  byte_length = 2
}

resource "google_kms_key_ring" "key_ring" {
  name     = "key-ring-${random_id.random_kms_suffix.hex}"
  location = local.region
  project  = var.project_id
}

resource "google_kms_crypto_key" "crypto_key" {
  name     = "crypto-key-${random_id.random_kms_suffix.hex}s"
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

module "secret-manager" {
  source     = "../../"
  project_id = var.project_id
  secrets = [
    {
      name        = "secret-1"
      secret_data = "secret information"
    },
  ]
  user_managed_replication = {
    secret-1 = [
      {
        location     = local.region
        kms_key_name = google_kms_crypto_key.crypto_key.id
      },
    ]
  }

  depends_on = [
    google_kms_crypto_key_iam_member.sm_sa_encrypter_decrypter
  ]
}
