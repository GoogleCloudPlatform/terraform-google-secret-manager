// Copyright 2024 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

package cloud_run

import (
	"errors"
	"fmt"
	"strings"
	"testing"
	"time"

	"github.com/GoogleCloudPlatform/cloud-foundation-toolkit/infra/blueprint-test/pkg/gcloud"
	"github.com/GoogleCloudPlatform/cloud-foundation-toolkit/infra/blueprint-test/pkg/tft"
	"github.com/GoogleCloudPlatform/cloud-foundation-toolkit/infra/blueprint-test/pkg/utils"
	"github.com/stretchr/testify/assert"
)

func TestMonitoringAlertSecret(t *testing.T) {
	vars := map[string]interface{}{
		"keyring": "test_keyring",
		"key":     "test_key",
	}

	secretT := tft.NewTFBlueprintTest(t, tft.WithVars(vars))

	projectId := secretT.GetTFOptions().EnvVars["TF_VAR_project_id"]
	projectNumber := gcloud.Runf(t, "projects describe %s", projectId).Get("projectNumber").String()
	gcloud.Runf(t, "iam service-accounts enable %s-compute@developer.gserviceaccount.com --project=%s", projectNumber, projectId)

	secretT.DefineVerify(func(assert *assert.Assertions) {
		secretT.DefaultVerify(assert)

		outputSecretPath := strings.Split(secretT.GetJsonOutput("secret_names").Array()[0].String(), "/")
		outputSecretName := outputSecretPath[len(outputSecretPath)-1]
		secretDescribe := gcloud.Runf(t, "secrets describe %s --project %s", outputSecretName, projectId)
		secretName := secretDescribe.Get("name").String()
		assert.Equal(fmt.Sprintf("projects/%s/secrets/%s", projectNumber, outputSecretName), secretName, "has expected name")
		replicationReplicas := secretDescribe.Get("replication.userManaged.replicas").Array()
		assert.Len(replicationReplicas, 1)
		assert.Equal(secretT.GetStringOutput("kms_key_name"), replicationReplicas[0].Get("customerManagedEncryption.kmsKeyName").String())
		topics := secretDescribe.Get("topics").Array()
		assert.Len(topics, 1)
		outputTopic := secretT.GetStringOutput("topic")
		assert.Equal(outputTopic, topics[0].Get("name").String())

		cloudRunFunctions := gcloud.Runf(t, "functions list --v2 --project %s --filter serviceConfig.uri='%s'", projectId, secretT.GetStringOutput("cloud_function_uri")).Array()
		assert.Len(cloudRunFunctions, 1)
		cloudRunFunction := cloudRunFunctions[0]
		assert.Equal("google.cloud.pubsub.topic.v1.messagePublished", cloudRunFunction.Get("eventTrigger.eventType").String())
		assert.Equal(outputTopic, cloudRunFunction.Get("eventTrigger.pubsubTopic").String())
		assert.Equal("ALLOW_INTERNAL_ONLY", cloudRunFunction.Get("serviceConfig.ingressSettings").String())
		assert.Equal("ACTIVE", cloudRunFunction.Get("state").String())

		gcloud.Runf(t, "secrets versions destroy %s/versions/1 -q", secretName)
		utils.Poll(t, func() (bool, error) {
			destroyLog := gcloud.Runf(t, "logging read textPayload:\"SM_DESTROY_EVENT\" --freshness=3m --project %s", projectId).Array()
			infoLog := gcloud.Runf(t, "logging read textPayload:\"SM_EVENT\" --freshness=3m --project %s", projectId).Array()
			if len(destroyLog) > 0 && len(infoLog) > 0 {
				assert.Contains(destroyLog[0].Get("textPayload").String(), fmt.Sprintf("A secret from %s was destroyed!", secretName))
				assert.Contains(destroyLog[0].Get("textPayload").String(), "\"state\":\"DESTROYED\"")
				assert.Equal("WARNING", destroyLog[0].Get("severity").String())
				assert.Contains(infoLog[0].Get("textPayload").String(), fmt.Sprintf("The event SECRET_VERSION_DESTROY occured on %s.", secretName))
				assert.Contains(infoLog[0].Get("textPayload").String(), "\"state\":\"DESTROYED\"")
				assert.Equal("INFO", infoLog[0].Get("severity").String())
				return false, nil
			}
			return true, errors.New("Notification wasn't fired correctly.")
		},
			/* numRetries= */ 20,
			/* interval= */ 10*time.Second)

	})
	secretT.Test()
}
