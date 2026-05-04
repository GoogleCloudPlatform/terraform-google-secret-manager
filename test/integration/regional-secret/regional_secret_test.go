// Copyright 2026 Google LLC
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

const regionalSecretLocation = "us-central1"

func TestRegionalSecret(t *testing.T) {
	secretT := tft.NewTFBlueprintTest(t)

	secretT.DefineVerify(func(assert *assert.Assertions) {
		secretT.DefaultVerify(assert)

		projectID := secretT.GetTFSetupStringOutput("project_id")
		projectDescribe := gcloud.Runf(t, "projects describe %s", projectID)
		projectNumber := projectDescribe.Get("projectNumber").String()

		fullSecretName := secretT.GetStringOutput("secret_name")
		parts := strings.Split(fullSecretName, "/")
		secretID := parts[len(parts)-1]

		baseURL := fmt.Sprintf(
			"https://secretmanager.%s.rep.googleapis.com/v1/projects/%s/locations/%s/secrets/%s",
			regionalSecretLocation, projectID, regionalSecretLocation, secretID,
		)

		// --- Secret describe ---
		secret, err := getJSON(t, baseURL)
		if err != nil {
			assert.FailNow("failed to GET regional secret", err)
		}

		assert.Equal(
			fmt.Sprintf("projects/%s/locations/%s/secrets/%s", projectNumber, regionalSecretLocation, secretID),
			secret.Get("name").String(),
			"secret has expected fully-qualified name",
		)
		assert.Equal("my-label", secret.Get("labels.label").String(), "secret has expected label")
		assert.Equal(
			"Regional secret example with CMEK, rotation and granular IAM",
			secret.Get("annotations.description").String(),
			"secret has expected description annotation",
		)
		assert.Equal("platform-team", secret.Get("annotations.owner").String(), "secret has expected owner annotation")

		topic := secret.Get("topics.0.name").String()
		assert.True(
			strings.HasPrefix(topic, fmt.Sprintf("projects/%s/topics/", projectID)),
			"secret has at least one topic in the expected project: %s", topic,
		)

		assert.Equal("2030-01-01T00:00:01Z", secret.Get("rotation.nextRotationTime").String(), "rotation next time matches")
		assert.Equal("31536000s", secret.Get("rotation.rotationPeriod").String(), "rotation period matches")

		kmsKey := secret.Get("customerManagedEncryption.kmsKeyName").String()
		assert.True(
			strings.HasPrefix(kmsKey, fmt.Sprintf("projects/%s/locations/%s/keyRings/", projectID, regionalSecretLocation)),
			"CMEK key is in the same project and region: %s", kmsKey,
		)

		// --- Secret version describe ---
		secretVersion, err := getJSON(t, fmt.Sprintf("%s/versions/1", baseURL))
		if err != nil {
			assert.FailNow("failed to GET regional secret version", err)
		}
		assert.Equal(
			fmt.Sprintf("projects/%s/locations/%s/secrets/%s/versions/1", projectNumber, regionalSecretLocation, secretID),
			secretVersion.Get("name").String(),
			"secret version has expected name",
		)
		assert.Equal("ENABLED", secretVersion.Get("state").String(), "secret version is ENABLED")

		// --- IAM policy ---
		iamPolicy, err := getJSON(t, fmt.Sprintf("%s:getIamPolicy", baseURL))
		if err != nil {
			assert.FailNow("failed to GET regional secret IAM policy", err)
		}

		expectedRoles := map[string]bool{
			"roles/secretmanager.secretAccessor": false,
			"roles/secretmanager.viewer":         false,
		}
		smIdentity := fmt.Sprintf(
			"serviceAccount:service-%s@gcp-sa-secretmanager.iam.gserviceaccount.com",
			projectNumber,
		)
		for _, b := range iamPolicy.Get("bindings").Array() {
			role := b.Get("role").String()
			if _, ok := expectedRoles[role]; !ok {
				continue
			}
			expectedRoles[role] = true
			members := b.Get("members").Array()
			found := false
			for _, m := range members {
				if m.String() == smIdentity {
					found = true
					break
				}
			}
			assert.True(found, "role %s should include the Secret Manager service identity", role)
		}
		for role, seen := range expectedRoles {
			assert.True(seen, "expected role %s to be configured on the secret", role)
		}
	})
	secretT.Test()
}

func getJSON(t *testing.T, url string) (*gjson.Result, error) {
	req, err := http.NewRequest("GET", url, nil)
	if err != nil {
		return nil, err
	}
	token := gcloud.Run(t, "auth print-access-token").Get("token").String()
	req.Header.Set("Authorization", fmt.Sprintf("Bearer %s", token))

	resp, err := (&http.Client{}).Do(req)
	if err != nil {
		return nil, err
	}
	defer resp.Body.Close()
	if resp.StatusCode != http.StatusOK {
		body, _ := io.ReadAll(resp.Body)
		return nil, fmt.Errorf("HTTP %s on %s: %s", resp.Status, url, string(body))
	}
	body, err := io.ReadAll(resp.Body)
	if err != nil {
		return nil, err
	}
	parsed := gjson.ParseBytes(body)
	return &parsed, nil
}
