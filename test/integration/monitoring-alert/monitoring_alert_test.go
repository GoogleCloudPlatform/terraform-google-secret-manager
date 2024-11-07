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

package monitoring_alert

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

var tests = []struct {
	test_name           string
	email_addresses     []string
	monitor_all_secrets bool
	run_destroy_check   bool
}{
	{"Monitor only created secret", []string{"email@example.com"}, false, true},
	{"Monitor all secrets", []string{"email@example.com", "email2@example.com"}, true, false},
}

func TestMonitoringAlertSecret(t *testing.T) {
	for _, tt := range tests {
		t.Run(tt.test_name, func(t *testing.T) {
			vars := map[string]interface{}{
				"email_addresses":     tt.email_addresses,
				"monitor_all_secrets": tt.monitor_all_secrets,
			}
			secretT := tft.NewTFBlueprintTest(t, tft.WithVars(vars))

			secretT.DefineVerify(func(assert *assert.Assertions) {
				secretT.DefaultVerify(assert)

				outputSecretPath := strings.Split(secretT.GetStringOutput("secret_name"), "/")
				outputSecretName := outputSecretPath[len(outputSecretPath)-1]
				projectId := secretT.GetStringOutput("project_id")
				projectDescribe := gcloud.Runf(t, "projects describe %s", projectId)
				projectNumber := projectDescribe.Get("projectNumber").String()
				secretDescribe := gcloud.Runf(t, "secrets describe %s --project %s", outputSecretName, projectId)
				secretName := secretDescribe.Get("name").String()
				assert.Equal(fmt.Sprintf("projects/%s/secrets/%s", projectNumber, outputSecretName), secretName, "has expected name")

				notificationChannelNames := secretT.GetJsonOutput("notification_channel_names").Array()
				assert.Len(notificationChannelNames, len(tt.email_addresses))
				notificationChannelEmailAddresses := []string{}
				notificationChannelStringNames := []string{}
				for _, notificationChannelName := range notificationChannelNames {
					notificationChannelStringNames = append(notificationChannelStringNames, notificationChannelName.String())
					monitoringChannel := gcloud.Runf(t, "beta monitoring channels list --project %s --filter name='%s'", projectId, notificationChannelName.String()).Array()
					assert.Len(monitoringChannel, 1)
					notificationChannelEmailAddresses = append(notificationChannelEmailAddresses, monitoringChannel[0].Get("labels.email_address").String())
				}
				assert.ElementsMatch(tt.email_addresses, notificationChannelEmailAddresses)

				monitoringAlerts := gcloud.Runf(t, "alpha monitoring policies list --project %s", projectId).Array()
				assert.Len(monitoringAlerts, 1)
				monitoringAlert := monitoringAlerts[0]
				alertCondition := monitoringAlerts[0].Get("conditions").Array()
				assert.Len(alertCondition, 1)
				var expectedFilter string
				if tt.monitor_all_secrets {
					expectedFilter = "protoPayload.methodName=\"google.cloud.secretmanager.v1.SecretManagerService.DestroySecretVersion\""
				} else {
					expectedFilter = fmt.Sprintf("protoPayload.methodName=\"google.cloud.secretmanager.v1.SecretManagerService.DestroySecretVersion\" AND protoPayload.resourceName : \"%s\"", secretT.GetStringOutput("secret_name"))
				}
				assert.Equal(expectedFilter, alertCondition[0].Get("conditionMatchedLog.filter").String())
				notificationChannels := monitoringAlert.Get("notificationChannels").Array()
				assert.Len(notificationChannels, len(tt.email_addresses))
				for _, notificationChannel := range notificationChannels {
					assert.Contains(notificationChannelStringNames, notificationChannel.String())
				}
				assert.Equal("WARNING", monitoringAlert.Get("severity").String())
				assert.Equal("300s", monitoringAlert.Get("alertStrategy.notificationRateLimit.period").String())
				assert.True(monitoringAlert.Get("enabled").Bool())

				if tt.run_destroy_check {
					time.Sleep(5 * time.Minute)
					gcloud.Runf(t, "secrets versions destroy %s/versions/1 -q", secretName)
					utils.Poll(t, func() (bool, error) {
						alertingLogs := gcloud.Runf(t, "logging read logName:\"projects/%s/logs/monitoring.googleapis.com\" --freshness=2m --project %s", projectId, projectId).Array()
						for _, log := range alertingLogs {
							expectedLogMessage := fmt.Sprintf("Log match condition fired for Audited Resource with {method=google.cloud.secretmanager.v1.SecretManagerService.DestroySecretVersion, project_id=%s, service=secretmanager.googleapis.com}", projectId)
							logMessage := log.Get("labels.verbose_message").String()
							expectedLogName := fmt.Sprintf("projects/%s/logs/monitoring.googleapis.com", projectId)
							logName := log.Get("logName").String()
							if strings.Contains(logMessage, expectedLogMessage) && strings.Contains(logName, expectedLogName) {
								// Test succeded.
								return false, nil
							}
						}
						return true, errors.New("Alert wasn't fired correctly.")
					},
						/* numRetries= */ 20,
						/* interval= */ 10*time.Second)
				}
			})
			secretT.Test()
		})
	}
}
