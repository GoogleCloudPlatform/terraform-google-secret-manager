package monitoring_alert

import (
	"fmt"
	"testing"

	"github.com/GoogleCloudPlatform/cloud-foundation-toolkit/infra/blueprint-test/pkg/gcloud"
	"github.com/GoogleCloudPlatform/cloud-foundation-toolkit/infra/blueprint-test/pkg/tft"
	"github.com/stretchr/testify/assert"
)

func TestMonitoringAlertSecret(t *testing.T) {
	secretT := tft.NewTFBlueprintTest(t)

	secretT.DefineVerify(func(assert *assert.Assertions) {
		secretT.DefaultVerify(assert)

		projectDescribe := gcloud.Runf(t, "projects describe %s", secretT.GetStringOutput("project_id"))
		projectNUM := projectDescribe.Get("projectNumber").String()
		secretDescribe := gcloud.Runf(t, "secrets describe %s --project %s", "secret-1", secretT.GetStringOutput("project_id"))
		secretName := secretDescribe.Get("name").String()
		assert.Equal(fmt.Sprintf("projects/%s/secrets/secret-1", projectNUM), secretName, "has expected name")

		monitoringChannel := gcloud.Runf(t, "beta monitoring channels list --project %s --filter name='%s' --format=json", secretT.GetStringOutput("project_id"), secretT.GetStringOutput("notification_channel_name")).Array()
		assert.Len(monitoringChannel, 1)
		assert.Equal("email@example.com", monitoringChannel[0].Get("labels.email_address").String())

		monitoringAlerts := gcloud.Runf(t, "alpha monitoring policies list --project %s --format=json", secretT.GetStringOutput("project_id")).Array()
		assert.Len(monitoringAlerts, 1)
		monitoringAlert := monitoringAlerts[0]
		alertCondition := monitoringAlerts[0].Get("conditions").Array()
		assert.Len(alertCondition, 1)
		expectedFilter := fmt.Sprintf("protoPayload.serviceName=\"secretmanager.googleapis.com\" AND protoPayload.methodName=\"google.cloud.secretmanager.v1.SecretManagerService.DestroySecretVersion\" AND protoPayload.resourceName : \"%s\"", secretT.GetJsonOutput("secret_names").Array()[0].String())
		assert.Equal(expectedFilter, alertCondition[0].Get("conditionMatchedLog.filter").String())
		notificationChannel := monitoringAlert.Get("notificationChannels").Array()[0].String()
		assert.Equal(secretT.GetStringOutput("notification_channel_name"), notificationChannel)
		assert.Equal("WARNING", monitoringAlert.Get("severity").String())
		assert.Equal("300s", monitoringAlert.Get("alertStrategy.notificationRateLimit.period").String())
		assert.True(monitoringAlert.Get("enabled").Bool())
	})
	secretT.Test()
}
