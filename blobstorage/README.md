# chart-blobstorage

[![Build Status](https://dev.azure.com/hmcts/CNP/_apis/build/status/Helm%20Charts/chart-blobstorage)](https://dev.azure.com/hmcts/CNP/_build/latest?definitionId=62)

This chart is intended for adding the azure blob storage service to the application.

We will take small PRs and small features to this chart but more complicated needs should be handled in your own chart.

## Example configuration

```yaml
resourceGroup: "your application resource group"
setup:
  containers:
   - first-container
   - second-container
```
**NOTE**: at least one container and the resource group are required for the blob storage service to provision the account and container(s) required for the application.

## Using it in your helm chart.
To get the container(s) access key and blob service endpoint needed in your application you need to use the secrets map that is available once the storage account and container(s) are provisioned.

In the **Java** chart section under the `secrets:` section.
```yaml
blobstorage:
    resourceGroup: yyyy
    setup:
      containers:
      - first-container
      - second-container
java:
  secrets:
    BLOB_ACCOUNT_NAME:
      secretRef: storage-secret-${SERVICE_NAME}
      key: storageAccountName
    BLOB_ACCESS_KEY:
      secretRef: storage-secret-${SERVICE_NAME}
      key: accessKey
    BLOB_SERVICE_ENDPOINT:
      secretRef: storage-secret-${SERVICE_NAME}
      key: primaryBlobServiceEndPoint
```

## Configuration

The following table lists the configurable parameters of the Blob Storage chart and their default values.

| Parameter      | Type | Description | Default |
| -------------- | ---- | ----------- | ------- |
| `location` | string | location of the PaaS instance of the blob storage to use | `uksouth` |
| `resourceGroup` | string | This is the resource group required for the azure deployment |  **Required** |
| `setup` | array | see the full description of the setup objects in [setup objects](#setupobjects)| **Required** |
| `setup.containers` | array | The names of the containers. | **Required**|
| `setup.enableNonHttpsTraffic` | `string` |  Specify whether non-https traffic is enabled. | `disabled`|


## Setup Objects
Currently we support only multiple `container(s)` setup within a single blob storage account. This should be flexible enough to cover all use cases.

 The container object definition is:
```yaml
setup:
  containers:
  - yourContainer
```

## Development and Testing

Default configuration (e.g. default image and ingress host) is setup for sandbox. This is suitable for local development and testing.

- Ensure you have logged in with `az cli` and are using `sandbox` subscription (use `az account show` to display the current one).
- For local development see the `Makefile` for available targets.
- To execute an end-to-end build, deploy and test run `make`.
- to clean up deployed releases, charts, test pods and local charts, run `make clean`

`helm test` will deploy a busybox container alongside the release which performs a simple HTTP "list containers" request against the blobstorage account endpoint. If it doesn't return `HTTP 200` the test will fail. **NOTE:** it does NOT run with `--cleanup` so the test pod will be available for inspection.

## Azure DevOps Builds

Builds are run against the 'nonprod' AKS cluster.

### Pull Request Validation

A build is triggered when pull requests are created. This build will run `helm lint`, deploy the chart using `ci-values.yaml` and run `helm test`.

### Release Build

Triggered when the repository is tagged (e.g. when a release is created). Also performs linting and testing, and will publish the chart to ACR on success.
