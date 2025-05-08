# Upgrading to Secret Manager  v0.7.0 from v0.6.0
The v0.7.0 release is backward incompatible release for `modules/simple-secret`.

## Impact is on `modules/simple-secret`
In the release v0.6.0, the secret version creation was optional and dependent on the presence of secret_data
in the input variable. By default it was `null` and no secret version was created.
In the release v0.7.0, the secret version creation is not optional and `secret_data` is required input variable.


```diff
module "secret-manager" {
  source  = "GoogleCloudPlatform/secret-manager/google//modules/simple-secret"
- version = "~> 0.6.0"
+ version = "~> 0.7.0"

  project_id  = var.project_id
  name        = "secret-1"
+ secret_data = "secret information"
}
```

All the users need to provide `secret_data` explicilty to create secret version.
