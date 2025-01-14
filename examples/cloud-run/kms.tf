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
  key_name = "${var.key}-${random_string.suffix.result}"
}

resource "google_kms_crypto_key_iam_member" "sm_sa_encrypter_decrypter" {
  role          = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
  member        = "serviceAccount:${google_project_service_identity.secretmanager_identity.email}"
  crypto_key_id = module.kms.keys[local.key_name]
}

module "kms" {
  source  = "terraform-google-modules/kms/google"
  version = "~> 3.2.0"

  keyring              = "${var.keyring}-${random_string.suffix.result}"
  location             = var.region
  project_id           = var.project_id
  keys                 = [local.key_name]
  purpose              = "ENCRYPT_DECRYPT"
  key_protection_level = "HSM"
  prevent_destroy      = false
}
