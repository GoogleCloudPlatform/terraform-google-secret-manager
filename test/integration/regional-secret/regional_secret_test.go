// Copyright 2022 Google LLC
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

package regional_secret

import (
	"fmt"
	"io"
	"net/http"
	"strings"
	"testing"

	"github.com/GoogleCloudPlatform/cloud-foundation-toolkit/infra/blueprint-test/pkg/gcloud"
	"github.com/GoogleCloudPlatform/cloud-foundation-toolkit/infra/blueprint-test/pkg/tft"
	"github.com/stretchr/testify/assert"
	"github.com/tidwall/gjson"
)

func TestRegionalSecret(t *testing.T) {
	secretT := tft.NewTFBlueprintTest(t)

	secretT.DefineVerify(func(assert *assert.Assertions) {
		secretT.DefaultVerify(assert)

		projectId := secretT.GetTFSetupStringOutput("project_id")
		projectDescribe := gcloud.Runf(t, "projects describe %s", projectId)
		projectNumber := projectDescribe.Get("projectNumber").String()
		fullSecretName := secretT.GetJsonOutput("secret_names").Array()[0].String()
		outputSecretPath := strings.Split(fullSecretName, "/")
		outputSecretName := outputSecretPath[len(outputSecretPath)-1]
		secretUrl := fmt.Sprintf("https://secretmanager.%s.rep.googleapis.com/v1/projects/%s/locations/%s/secrets/%s", "us-central1", projectId, "us-central1", outputSecretName)
		secret, err := makeRequestToApi(t, secretUrl)
		if err != nil {
			assert.FailNow("Failed to make request to API", err)
		}
		assert.Equal(fmt.Sprintf("projects/%s/locations/us-central1/secrets/%s", projectNumber, outputSecretName), secret.Get("name").String(), "has expected name")
		assert.Equal("my-label", secret.Get("labels").Get("label").String(), "has expected label")
		expectedTopicName := fmt.Sprintf("projects/%s/topics", projectId)
		assert.Contains(secret.Get("topics").Array()[0].String(), expectedTopicName, "has expected topic name")
		assert.Equal("2030-01-01T00:00:01Z", secret.Get("rotation.nextRotationTime").String(), "has expected next rotation time")
		assert.Equal("31536000s", secret.Get("rotation.rotationPeriod").String(), "has expected rotation period")
		expectedKmsKeyName := fmt.Sprintf("projects/%s/locations/us-central1/keyRings", projectId)
		assert.Contains(secret.Get("customerManagedEncryption.kmsKeyName").String(), expectedKmsKeyName, "has expected KMS key name")

		secretVersionUrl := fmt.Sprintf("%s/versions/1", secretUrl)
		secretVersion, err := makeRequestToApi(t, secretVersionUrl)
		if err != nil {
			assert.FailNow("Failed to make request to API", err)
		}
		assert.Equal(fmt.Sprintf("projects/%s/locations/us-central1/secrets/%s/versions/1", projectNumber, outputSecretName), secretVersion.Get("name").String(), "has expected name")
		assert.Equal("ENABLED", secretVersion.Get("state").String(), "has expected state")
		assert.Contains(secret.Get("customerManagedEncryption.kmsKeyName").String(), expectedKmsKeyName, "has expected KMS key name")
	})
	secretT.Test()
}

func makeRequestToApi(t *testing.T, url string) (*gjson.Result, error) {
	req, err := http.NewRequest("GET", url, nil)
	if err != nil {
		return nil, err
	}

	accessToken := gcloud.Run(t, "auth print-access-token").Get("token").String()
	req.Header.Set("Authorization", fmt.Sprintf("Bearer %s", accessToken))
	client := &http.Client{}
	resp, err := client.Do(req)
	if err != nil {
		return nil, err
	}
	defer resp.Body.Close()
	if resp.StatusCode != http.StatusOK {
		return nil, fmt.Errorf("error: %s", resp.Status)
	}
	body, err := io.ReadAll(resp.Body)
	if err != nil {
		return nil, err
	}

	json := gjson.ParseBytes(body)
	return &json, nil
}
