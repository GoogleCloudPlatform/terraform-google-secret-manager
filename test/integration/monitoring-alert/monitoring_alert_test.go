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

func TestMonitoringAlertSecret(t *testing.T) {
	email_address := "email@example.com"
	vars := map[string]interface{}{
		"email_addresses": []string{email_address},
	}

	secretT := tft.NewTFBlueprintTest(t, tft.WithVars(vars))

	secretT.DefineVerify(func(assert *assert.Assertions) {
		secretT.DefaultVerify(assert)

		projectId := secretT.GetStringOutput("project_id")
		projectDescribe := gcloud.Runf(t, "projects describe %s", projectId)
		projectNumber := projectDescribe.Get("projectNumber").String()
		secretDescribe := gcloud.Runf(t, "secrets describe %s --project %s", "secret-1", projectId)
		secretName := secretDescribe.Get("name").String()
		assert.Equal(fmt.Sprintf("projects/%s/secrets/secret-1", projectNumber), secretName, "has expected name")

		notificationChannelNames := secretT.GetJsonOutput("notification_channel_names").Array()
		assert.Len(notificationChannelNames, 1)
		notificationChannelName := notificationChannelNames[0].String()
		monitoringChannel := gcloud.Runf(t, "beta monitoring channels list --project %s --filter name='%s'", projectId, notificationChannelName).Array()
		assert.Len(monitoringChannel, 1)
		assert.Equal(email_address, monitoringChannel[0].Get("labels.email_address").String())

		monitoringAlerts := gcloud.Runf(t, "alpha monitoring policies list --project %s", projectId).Array()
		assert.Len(monitoringAlerts, 1)
		monitoringAlert := monitoringAlerts[0]
		alertCondition := monitoringAlerts[0].Get("conditions").Array()
		assert.Len(alertCondition, 1)
		expectedFilter := fmt.Sprintf("protoPayload.methodName=\"google.cloud.secretmanager.v1.SecretManagerService.DestroySecretVersion\" AND protoPayload.resourceName : \"%s\"", secretT.GetJsonOutput("secret_names").Array()[0].String())
		assert.Equal(expectedFilter, alertCondition[0].Get("conditionMatchedLog.filter").String())
		notificationChannel := monitoringAlert.Get("notificationChannels").Array()[0].String()
		assert.Equal(notificationChannelName, notificationChannel)
		assert.Equal("WARNING", monitoringAlert.Get("severity").String())
		assert.Equal("300s", monitoringAlert.Get("alertStrategy.notificationRateLimit.period").String())
		assert.True(monitoringAlert.Get("enabled").Bool())

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
		}, 200, 10*time.Second)
	})
	secretT.Test()
}

func TestMonitoringAlertAllSecrets(t *testing.T) {
	email_addresses := []string{"email@example.com", "email2@example.com"}
	vars := map[string]interface{}{
		"email_addresses":     email_addresses,
		"monitor_all_secrets": true,
	}

	secretT := tft.NewTFBlueprintTest(t, tft.WithVars(vars))

	secretT.DefineVerify(func(assert *assert.Assertions) {
		secretT.DefaultVerify(assert)
		projectId := secretT.GetStringOutput("project_id")
		projectDescribe := gcloud.Runf(t, "projects describe %s", projectId)
		projectNumber := projectDescribe.Get("projectNumber").String()
		secretDescribe := gcloud.Runf(t, "secrets describe %s --project %s", "secret-1", projectId)
		secretName := secretDescribe.Get("name").String()
		assert.Equal(fmt.Sprintf("projects/%s/secrets/secret-1", projectNumber), secretName, "has expected name")

		notificationChannelNames := secretT.GetJsonOutput("notification_channel_names").Array()
		assert.Len(notificationChannelNames, 2)
		notificationChannelName := notificationChannelNames[0].String()
		monitoringChannel := gcloud.Runf(t, "beta monitoring channels list --project %s --filter name='%s'", projectId, notificationChannelName).Array()
		assert.Len(monitoringChannel, 1)
		notificationChannelName2 := notificationChannelNames[1].String()
		monitoringChannel2 := gcloud.Runf(t, "beta monitoring channels list --project %s --filter name='%s'", projectId, notificationChannelName2).Array()
		assert.Len(monitoringChannel2, 1)
		assert.ElementsMatch(email_addresses, []string{monitoringChannel[0].Get("labels.email_address").String(), monitoringChannel2[0].Get("labels.email_address").String()})

		monitoringAlerts := gcloud.Runf(t, "alpha monitoring policies list --project %s", projectId).Array()
		assert.Len(monitoringAlerts, 1)
		monitoringAlert := monitoringAlerts[0]
		alertCondition := monitoringAlerts[0].Get("conditions").Array()
		assert.Len(alertCondition, 1)
		expectedFilter := "protoPayload.methodName=\"google.cloud.secretmanager.v1.SecretManagerService.DestroySecretVersion\""
		assert.Equal(expectedFilter, alertCondition[0].Get("conditionMatchedLog.filter").String())
		notificationChannels := monitoringAlert.Get("notificationChannels").Array()
		assert.Len(notificationChannels, 2)
		assert.ElementsMatch([]string{notificationChannelName, notificationChannelName2}, []string{notificationChannels[0].String(), notificationChannels[1].String()})
		assert.Equal("WARNING", monitoringAlert.Get("severity").String())
		assert.Equal("300s", monitoringAlert.Get("alertStrategy.notificationRateLimit.period").String())
		assert.True(monitoringAlert.Get("enabled").Bool())
	})
	secretT.Test()
}
