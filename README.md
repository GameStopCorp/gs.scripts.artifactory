# gs.scripts.artifactory

This repository contains bash scripts that facilitate interaction with GameStop's Jfrog Artifactory.

## Usage

### To download a key

```bash
source /gs.scripts.artifactory/src/artifactory_helper.sh
acquireArtifactoryToken bucket-name keyname $result
echo $result
```

### To upload an artifact

```bash
source /gs.scripts.artifactory/src/artifactory_helper.sh
uploadArtifact $repo $package $apiKey result
```

### To download an artifact

```bash
source /gs.scripts.artifactory/src/artifactory_helper.sh
downloadArtifact $repo $package $fileName $apiKey result
```

### To set the commit stage status to FAILED on an artifact

```bash
source /gs.scripts.artifactory/src/item_properties.sh
setArtifactCommitFail user apiKey npm-local/@gamestop/bunyan-lambda/-/@gamestop/bunyan-lambda-2.1.4.tgz
```

### To set the commit stage status to PASSED on an artifact

```bash
source /gs.scripts.artifactory/src/item_properties.sh
setArtifactCommitPass user apiKey npm-local/@gamestop/bunyan-lambda/-/@gamestop/bunyan-lambda-2.1.4.tgz
```

### To (generically) set a stage status on an artifact

```bash
source /gs.scripts.artifactory/src/item_properties.sh
setArtifactStageStatus user apiKey npm-local/@gamestop/bunyan-lambda/-/@gamestop/bunyan-lambda-2.1.4.tgz test FAILURE
```

### To (even more generically) set an artifact item property and value

```bash
source /gs.scripts.artifactory/src/item_properties.sh
setArtifactPropertyValue user apiKey npm-local/@gamestop/bunyan-lambda/-/@gamestop/bunyan-lambda-2.1.4.tgz stage.test.status FAILURE
```
