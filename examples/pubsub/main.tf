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

resource "random_id" "random_topic_id_suffix" {
  byte_length = 2
}

resource "google_pubsub_topic" "secret" {
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
  topic   = google_pubsub_topic.secret.name
}

module "secret-manager" {
  source     = "../../"
  project_id = var.project_id
  secrets = [
    {
      name                  = "secret-1"
      automatic_replication = true
      next_rotation_time    = "2024-10-02T15:01:23Z"
      rotation_period       = "31536000s"
      secret_data           = "secret information"
    },
  ]
  topics = {
    secret-1 = [
      {
        name = google_pubsub_topic.secret.id
      }
    ]
  }
  depends_on = [
    google_pubsub_topic_iam_member.sm_sa_publisher
  ]
}
