# Changelog

All notable changes to this project will be documented in this file.

The format is based on
[Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to
[Semantic Versioning](https://semver.org/spec/v2.0.0.html).
This changelog is generated automatically based on [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/).

## [0.9.0](https://github.com/GoogleCloudPlatform/terraform-google-secret-manager/compare/v0.8.0...v0.9.0) (2025-09-18)


### Features

* Add per module requirements to secret-manager ([#141](https://github.com/GoogleCloudPlatform/terraform-google-secret-manager/issues/141)) ([d5f21c8](https://github.com/GoogleCloudPlatform/terraform-google-secret-manager/commit/d5f21c806a94bf8b8c2f7862420af0e336856cd3))
* **deps:** Update Terraform Google Provider to v7 (major) ([#145](https://github.com/GoogleCloudPlatform/terraform-google-secret-manager/issues/145)) ([b9b834e](https://github.com/GoogleCloudPlatform/terraform-google-secret-manager/commit/b9b834edc6d3ae72910740b7bf82b12c2d0dc271))


### Bug Fixes

* Add UI validation for simple-secret ([#144](https://github.com/GoogleCloudPlatform/terraform-google-secret-manager/issues/144)) ([830e822](https://github.com/GoogleCloudPlatform/terraform-google-secret-manager/commit/830e822000f210aad51e34f6b3e2d7a4f6315f57))

## [0.8.0](https://github.com/GoogleCloudPlatform/terraform-google-secret-manager/compare/v0.7.1...v0.8.0) (2025-03-05)


### Features

* add example with monitoring alert for secret version destruction ([#100](https://github.com/GoogleCloudPlatform/terraform-google-secret-manager/issues/100)) ([4b7a360](https://github.com/GoogleCloudPlatform/terraform-google-secret-manager/commit/4b7a360c715eb3c5e36c45d202db0ba486c2d634))

## [0.7.1](https://github.com/GoogleCloudPlatform/terraform-google-secret-manager/compare/v0.7.0...v0.7.1) (2025-02-04)


### Bug Fixes

* update output type for env_vars in metadata ([#126](https://github.com/GoogleCloudPlatform/terraform-google-secret-manager/issues/126)) ([099bc5d](https://github.com/GoogleCloudPlatform/terraform-google-secret-manager/commit/099bc5d2d3a6888f22b19abd938ec1bbe2eb0b4a))

## [0.7.0](https://github.com/GoogleCloudPlatform/terraform-google-secret-manager/compare/v0.6.0...v0.7.0) (2025-01-09)


### ⚠ BREAKING CHANGES

* make secret_data required to create secret version in simple-secret module ([#116](https://github.com/GoogleCloudPlatform/terraform-google-secret-manager/issues/116))

### Bug Fixes

* make secret_data required to create secret version in simple-secret module ([#116](https://github.com/GoogleCloudPlatform/terraform-google-secret-manager/issues/116)) ([c87f5fa](https://github.com/GoogleCloudPlatform/terraform-google-secret-manager/commit/c87f5fa5accab89e9b5b276bc68ccccf338c8079))

## [0.6.0](https://github.com/GoogleCloudPlatform/terraform-google-secret-manager/compare/v0.5.1...v0.6.0) (2025-01-07)


### Features

* add new output variable called env_vars ([#115](https://github.com/GoogleCloudPlatform/terraform-google-secret-manager/issues/115)) ([e89eb0a](https://github.com/GoogleCloudPlatform/terraform-google-secret-manager/commit/e89eb0a683d0d3ca32a366edc2ebe6c151bb31ad))


### Bug Fixes

* do not create secret version when secret_data is null ([#111](https://github.com/GoogleCloudPlatform/terraform-google-secret-manager/issues/111)) ([6294316](https://github.com/GoogleCloudPlatform/terraform-google-secret-manager/commit/629431642e2ebd15e441ee7501535cd1b2036e85))

## [0.5.1](https://github.com/GoogleCloudPlatform/terraform-google-secret-manager/compare/v0.5.0...v0.5.1) (2024-12-09)


### Bug Fixes

* **deps:** Update go modules and dev-tools ([#102](https://github.com/GoogleCloudPlatform/terraform-google-secret-manager/issues/102)) ([dfa3cde](https://github.com/GoogleCloudPlatform/terraform-google-secret-manager/commit/dfa3cde0f08bab77308151f5f49a17e50ce0730c))

## [0.5.0](https://github.com/GoogleCloudPlatform/terraform-google-secret-manager/compare/v0.4.0...v0.5.0) (2024-11-05)


### Features

* **deps:** Update Terraform Google Provider to v6 (major) ([#97](https://github.com/GoogleCloudPlatform/terraform-google-secret-manager/issues/97)) ([be1d845](https://github.com/GoogleCloudPlatform/terraform-google-secret-manager/commit/be1d84531e8581c37974a58ca6ffef63634f3096))
* **module:** Add a new module "secret" for managing a single secret ([#76](https://github.com/GoogleCloudPlatform/terraform-google-secret-manager/issues/76)) ([83217bc](https://github.com/GoogleCloudPlatform/terraform-google-secret-manager/commit/83217bcb14abe4ed3bec8f029a8062648a883910))

## [0.4.0](https://github.com/GoogleCloudPlatform/terraform-google-secret-manager/compare/v0.3.0...v0.4.0) (2024-07-19)


### ⚠ BREAKING CHANGES

* Change variable type for secrets ([#89](https://github.com/GoogleCloudPlatform/terraform-google-secret-manager/issues/89))
* Fix handling the CMEK with automatic replication ([#74](https://github.com/GoogleCloudPlatform/terraform-google-secret-manager/issues/74))

### Features

* Change variable type for secrets ([#89](https://github.com/GoogleCloudPlatform/terraform-google-secret-manager/issues/89)) ([468af0c](https://github.com/GoogleCloudPlatform/terraform-google-secret-manager/commit/468af0c034b586aec31a557326d8b61d1cbb7708))


### Bug Fixes

* Fix handling the CMEK with automatic replication ([#74](https://github.com/GoogleCloudPlatform/terraform-google-secret-manager/issues/74)) ([311a73f](https://github.com/GoogleCloudPlatform/terraform-google-secret-manager/commit/311a73f34b8a7e855366024289031a9cef80bf04))

## [0.3.0](https://github.com/GoogleCloudPlatform/terraform-google-secret-manager/compare/v0.2.0...v0.3.0) (2024-06-10)


### Features

* add support to specify secret accessors ([#66](https://github.com/GoogleCloudPlatform/terraform-google-secret-manager/issues/66)) ([a61b2ae](https://github.com/GoogleCloudPlatform/terraform-google-secret-manager/commit/a61b2aea5b7962a7a7ad9d7fe8d8c167ef620430))
* Make secrets data optional ([#61](https://github.com/GoogleCloudPlatform/terraform-google-secret-manager/issues/61)) ([5f78bea](https://github.com/GoogleCloudPlatform/terraform-google-secret-manager/commit/5f78bea92bbd13734e3488c18e6edc973ff46bd3))


### Bug Fixes

* changed deprecated auto replication attribute ([#31](https://github.com/GoogleCloudPlatform/terraform-google-secret-manager/issues/31)) ([6beaa66](https://github.com/GoogleCloudPlatform/terraform-google-secret-manager/commit/6beaa663d4c4ed254fb9433664261846891f2dd5))
* google_secret_manager_secret_iam_binding.binding for_each ([#72](https://github.com/GoogleCloudPlatform/terraform-google-secret-manager/issues/72)) ([4494e35](https://github.com/GoogleCloudPlatform/terraform-google-secret-manager/commit/4494e354495771294bb660f01360211ce4b3e73f))

## [0.2.0](https://github.com/GoogleCloudPlatform/terraform-google-secret-manager/compare/v0.1.1...v0.2.0) (2024-02-13)


### ⚠ BREAKING CHANGES

* **TPG>=4.83:** Update Terraform Google Provider to v5 ([#32](https://github.com/GoogleCloudPlatform/terraform-google-secret-manager/issues/32))

### Bug Fixes

* **TPG>=4.83:** Update Terraform Google Provider to v5 ([#32](https://github.com/GoogleCloudPlatform/terraform-google-secret-manager/issues/32)) ([b51196d](https://github.com/GoogleCloudPlatform/terraform-google-secret-manager/commit/b51196d6b1d7647ebf120a5084e6ad21c4c78f48))

## [0.1.1](https://github.com/GoogleCloudPlatform/terraform-google-secret-manager/compare/v0.1.0...v0.1.1) (2022-12-29)


### Bug Fixes

* fixes lint issues and generates metadata ([#3](https://github.com/GoogleCloudPlatform/terraform-google-secret-manager/issues/3)) ([652fa3a](https://github.com/GoogleCloudPlatform/terraform-google-secret-manager/commit/652fa3a17099c5cb808e8b55c45c08fd42e29cda))

## [0.1.0](https://github.com/terraform-google-modules/terraform-google-secret-manager/releases/tag/v0.1.0) - 20XX-YY-ZZ

### Features

- Initial release

[0.1.0]: https://github.com/terraform-google-modules/terraform-google-secret-manager/releases/tag/v0.1.0
