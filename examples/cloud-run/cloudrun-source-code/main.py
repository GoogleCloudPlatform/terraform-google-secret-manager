# Copyright 2024 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the 'License');
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an 'AS IS' BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

import base64
import logging

from cloudevents.http import CloudEvent
import google.cloud.logging
import functions_framework

cloud_logging_client = google.cloud.logging.Client()
cloud_logging_client.setup_logging()


# Triggered from a message on the Cloud Pub/Sub topic,
# which indicates an event occured in Secret Manager.
@functions_framework.cloud_event
def subscribe(cloud_event: CloudEvent) -> None:
    secret_metadata = base64.b64decode(
        cloud_event.data['message']['data']).decode()
    attributes = cloud_event.data['message']['attributes']
    event_type = attributes['eventType']
    secret_id = attributes['secretId']

    logging.info(f'SM_EVENT: The event {event_type} occured on {secret_id}. '
                 f'Secret metadata: {secret_metadata}.')

    # For this example, for demonstration purposes, we're handling only
    # secret destruction events. See list of all possible events:
    # https://cloud.google.com/secret-manager/docs/event-notifications#events.
    if event_type == 'SECRET_VERSION_DESTROY':
        return handle_destruction(secret_id, secret_metadata)


# Handles secret destruction. Can be used to send emails,
# add or remove database entries, and much more.
def handle_destruction(secret_id: str, secret_metadata: str) -> None:
    logging.warning(f'SM_DESTROY_EVENT: A secret from {secret_id} was '
                    f'destroyed! Secret metadata: {secret_metadata}')
