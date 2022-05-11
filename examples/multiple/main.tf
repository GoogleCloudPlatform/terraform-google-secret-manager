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

resource "random_id" "random_suffix" {
  byte_length = 2
}
resource "google_kms_key_ring" "key_ring_east" {
  name     = "key-ring-east-${random_id.random_suffix.hex}"
  location = "us-east1"
  project  = var.project_id
}

resource "google_kms_crypto_key" "crypto_key_east" {
  name     = "crypto-key-${random_id.random_suffix.hex}"
  key_ring = google_kms_key_ring.key_ring_east.id
}

resource "google_kms_key_ring" "key_ring_central" {
  name     = "key-ring-central-${random_id.random_suffix.hex}"
  location = "us-central1"
  project  = var.project_id
}

resource "google_kms_crypto_key" "crypto_key_central" {
  name     = "crypto-key-${random_id.random_suffix.hex}"
  key_ring = google_kms_key_ring.key_ring_central.id
}

resource "google_pubsub_topic" "secret_topic_1" {
  project = var.project_id
  name    = "topic-1-${random_id.random_suffix.hex}"
}

resource "google_pubsub_topic" "secret_topic_2" {
  project = var.project_id
  name    = "topic-2-${random_id.random_suffix.hex}"
}

module "secret-manager" {
  source     = "../../"
  project_id = var.project_id
  secrets = [
    {
      name               = "secret-1"
      next_rotation_time = "2024-10-02T15:01:23Z"
      rotation_period    = "31536000s"
      secret_data        = "my_secret"
    },
    {
      name                  = "secret-2"
      automatic_replication = true
      secret_data           = "my_secret2"
    },
    {
      name        = "secret-3"
      secret_data = "my_secret3"
    }
  ]
  user_managed_replication = {
    secret-1 = [
      {
        location     = "us-east1"
        kms_key_name = google_kms_crypto_key.crypto_key_east.id
      },
      {
        location     = "us-central1"
        kms_key_name = google_kms_crypto_key.crypto_key_central.id
      }
    ]
    secret-3 = [
      {
        location     = "us-central1"
        kms_key_name = google_kms_crypto_key.crypto_key_central.id
      },
    ]
  }
  topics = {
    secret-1 = [
      {
        name = google_pubsub_topic.secret_topic_1.id
      },
      {
        name = google_pubsub_topic.secret_topic_2.id
      }
    ]
  }
  labels = {
    secret-1 = {
      key1 : "value1",
      key2 : "value2"
    }
  }
  add_kms_permissions = [
    google_kms_crypto_key.crypto_key_east.id,
    google_kms_crypto_key.crypto_key_central.id
  ]
  add_pubsub_permissions = [
    google_pubsub_topic.secret_topic_1.id,
    google_pubsub_topic.secret_topic_2.id
  ]
}
