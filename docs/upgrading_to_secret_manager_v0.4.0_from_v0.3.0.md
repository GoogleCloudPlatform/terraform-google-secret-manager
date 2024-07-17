# Upgrading to Secret Manager v0.4.0 from v0.3.0
The v0.4.0 release is backward incompatible release.

## Impact
Secret version creation is optional in Secret Manager module. In the release
v0.3.0, the secret version creation was dependent on the presence of secret_data
in the input variable.
In the release v0.4.0, the secret version creation is dependent on the `create_version`
flag in the input data.

```diff
module "secret-manager" {
  source  = "GoogleCloudPlatform/secret-manager/google"
  version = "~> 0.3"

  project_id = var.project_id
  secrets = [
    {
      name           = "secret-1"
+     create_version = false
    },
  ]
}
```

All the users who don't want secret-version to be created needs to set `create_version` to false explicitly.

