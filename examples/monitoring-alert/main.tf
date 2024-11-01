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


module "secret-manager" {
  source  = "GoogleCloudPlatform/secret-manager/google"
  version = "~> 0.4"

  project_id = var.project_id
  secrets = [
    {
      name        = "secret-1"
      secret_data = "secret information"
    },
  ]
}

resource "google_monitoring_alert_policy" "alert_policy" {
  project      = var.project_id
  display_name = "Secret Deletion Alert"
  documentation {
    content = "Secret manager alert: one secret from ${module.secret-manager.secret_names[0]} was destroyed."
  }
  combiner = "OR"
  conditions {
    display_name = "Destroy condition"
    condition_matched_log {
      filter = join(" AND ", flatten([
        "protoPayload.methodName=\"google.cloud.secretmanager.v1.SecretManagerService.DestroySecretVersion\"",
        var.monitor_all_secrets ? [] : ["protoPayload.resourceName : \"${module.secret-manager.secret_names[0]}\""]
      ]))
    }
  }

  alert_strategy {
    notification_rate_limit {
      period = "300s"
    }
  }

  notification_channels = [for email_ch in google_monitoring_notification_channel.email_channel : email_ch.name]

  severity = "WARNING"
}

resource "google_monitoring_notification_channel" "email_channel" {
  for_each     = toset(var.email_addresses)
  project      = var.project_id
  display_name = "Secret deletion alert channel"
  type         = "email"
  description  = "Sends email notifications for secret deletion alerts"

  labels = {
    email_address = each.value
  }
}
