# chart-blobstorage

[![Build Status](https://dev.azure.com/hmcts/CNP/_apis/build/status/Helm%20Charts/chart-blobstorage)](https://dev.azure.com/hmcts/CNP/_build/latest?definitionId=62)

This helm chart is intended for creating an Azure Blob Storage resource for the application using [Azure Service Operator (ASO)|https://github.com/Azure/azure-service-operator]

We will take small PRs and small features to this chart but more complicated needs should be handled in your own chart.

## Migration to v1.0 (from OSBA to ASO)

### Cnp-flux-config
* [Follow the guidance within cnp-flux-config](https://github.com/hmcts/cnp-flux-config/blob/master/docs/aso-setup-v2.md#resource-group) on how to add a resource group for your ASO resources

### App repository changes
* The resource group you created in the previous step will now follow the pattern of {namespace}-aso-{env}-rg, this will need updated in your config

* There are now 2 separate secrets in the ASO version, so this will need updated within your app config

Examples of the secrets in the new ASO version

storage-account-{releaseName}-blobstorage
```yaml
apiVersion: v1
data:
  storage_account_name: value
kind: Secret
metadata:
  name: storage-account-{releaseName}-blobstorage
```

storage-secret-{releaseName}-blobstorage
```yaml
apiVersion: v1
data:
  accessKey: value
  blobEndpoint: value
  key2: value
kind: Secret
metadata:
  name: storage-secret-{releaseName}-blobstorage
```

The secret in the previous OSBA version had a name of the format storage-secret-{releaseName}

Example of the previous OSBA secret
```yaml
apiVersion: v1
data:
  accessKey: value
  primaryBlobServiceEndPoint: value
  storageAccountName: value
kind: Secret
metadata:
  name: storage-secret-{releaseName}
```

## Example configuration

```yaml
resourceGroup: "your application resource group"
setup:
  containers:
   - first-container
   - second-container
```
**NOTE**: 
    Required ResourceGroup has to be provisioned beforehand via flux. At least one container and the resource group are required for the blob storage service to provision the account and container(s) required for the application.
     
    
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
    STORAGE_ACCOUNT_NAME:
      secretRef: storage-account-{{ .Release.Name }}-blobstorage
      key: storage_account_name
    STORAGE_URL:
      secretRef: storage-secret-{{ .Release.Name }}-blobstorage
      key: blobEndpoint
    STORAGE_KEY:
      secretRef: storage-secret-{{ .Release.Name }}-blobstorage
      key: accessKey
```
If using releaseNameOverride, secretRef will be updated as in below

```yaml
releaseNameOverride: example-release-name
blobstorage:
    resourceGroup: yyyy
    setup:
      containers:
      - first-container
      - second-container
java:
  secrets:
    STORAGE_ACCOUNT_NAME:
      secretRef: storage-account-example-release-name
      key: storage_account_name
    STORAGE_URL:
      secretRef: storage-secret-example-release-name
      key: blobEndpoint
    STORAGE_KEY:
      secretRef: storage-secret-example-release-name
      key: accessKey
    
```

## Configuration

The following table lists the configurable parameters of the Blob Storage chart and their default values.

| Parameter      | Type | Description | Default |
| -------------- | ---- | ----------- | ------- |
| `releaseNameOverride`          | Will override the resource name - It supports templating, example:`releaseNameOverride: {{ .Release.Name }}-my-custom-name`      | `Release.Name-Chart.Name`     |
| `location` | string | location of the PaaS instance of the blob storage to use | `uksouth` |
| `resourceGroup` | string | resource group required for the Azure deployment |  **Required** |
| `setup` | array | see the full description of the setup objects in [setup objects](#setupobjects)| **Required** |
| `setup.containers` | array | The names of the containers. | **Required**|
| `setup.supportsHttpsTrafficOnly` | `bool` |  Specify whether https traffic is only enabled. | `true`|
| `tags.teamName`                   | string | team name used to create related Azure tag. This will usually be set by Jenkins through `global.`                                                                                                                                                                                                                                        | **Required if not set through `global.`** |
| `tags.applicationName`            | string | application name used to create necessary Azure tag. This will usually be set by Jenkins through `global.`                                                                                                                                                                                                                               | **Required if not set through `global.`** |
| `tags.builtFrom`                  | string | built from used to create necessary Azure tag. This will usually be set by Jenkins through `global.`                                                                                                                                                                                                                                     | **Required if not set through `global.`** |
| `tags.businessArea`               | string | business area used to create necessary Azure tag. This will usually be set by Jenkins through `global.`                                                                                                                                                                                                                                  | **Required if not set through `global.`** |
| `tags.environment`                | string | environment used to create necessary Azure tag. This will usually be set by Jenkins through `global.`                                                                                                                                                                                                                                    | **Required if not set through `global.`**                          |


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

Builds are run against the 'cft-preview' AKS cluster. Any troubleshooting can be done within the chart-tests namespace on the cft-preview cluster.

### Pull Request Validation

A build is triggered when pull requests are created. This build will run `helm lint`, deploy the chart using `ci-values.yaml` and run `helm test`.

### Release Build

Triggered when the repository is tagged (e.g. when a release is created). Also performs linting and testing, and will publish the chart to ACR on success.
