// Copyright 2025 Google LLC
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

package delayed_destruction

import (
	"fmt"
	"testing"

	"github.com/GoogleCloudPlatform/cloud-foundation-toolkit/infra/blueprint-test/pkg/gcloud"
	"github.com/GoogleCloudPlatform/cloud-foundation-toolkit/infra/blueprint-test/pkg/tft"
	"github.com/stretchr/testify/assert"
)

func TestDelayedDestruction(t *testing.T) {
	secretT := tft.NewTFBlueprintTest(t)

	secretT.DefineVerify(func(assert *assert.Assertions) {
		secretT.DefaultVerify(assert)

		projectDescribe := gcloud.Run(t, fmt.Sprintf("projects describe %s", secretT.GetTFSetupStringOutput("project_id")))
		projectNumber := projectDescribe.Get("projectNumber").String()

		secretDescribe := gcloud.Run(t, fmt.Sprintf("secrets describe %s --project %s", "secret-delayed-destruction-1", secretT.GetTFSetupStringOutput("project_id")))

		assert.Equal(fmt.Sprintf("projects/%s/secrets/secret-delayed-destruction-1", projectNumber), secretDescribe.Get("name").String(), "has expected name")
		assert.Equal("2592000s", secretDescribe.Get("versionDestroyTtl").String(), "has expected version destroy ttl")
	})
	secretT.Test()
}
