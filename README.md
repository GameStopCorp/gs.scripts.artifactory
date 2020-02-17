# MIGRATED
This repo has been migrated to GitLab at https://gitlab.com/gamestopcorp/platform/tools/artifactory-helper

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

### To set the commit stage status to FAIL on an artifact

```bash
source /gs.scripts.artifactory/src/item_properties.sh
setArtifactStageFail user apiKey npm-local/@gamestop/bunyan-lambda/-/@gamestop/bunyan-lambda-2.1.4.tgz commit
```

### To set the commit stage status to PASS on an artifact

```bash
source /gs.scripts.artifactory/src/item_properties.sh
setArtifactStagePass user apiKey npm-local/@gamestop/bunyan-lambda/-/@gamestop/bunyan-lambda-2.1.4.tgz commit
```

### To (generically) set the commit stage status value to FAIL on an artifact

```bash
source /gs.scripts.artifactory/src/item_properties.sh
setArtifactStageStatus user apiKey npm-local/@gamestop/bunyan-lambda/-/@gamestop/bunyan-lambda-2.1.4.tgz commit FAIL
```

### To (even more generically) set the commit stage status value to FAIL on an artifact

```bash
source /gs.scripts.artifactory/src/item_properties.sh
setArtifactPropertyValue user apiKey npm-local/@gamestop/bunyan-lambda/-/@gamestop/bunyan-lambda-2.1.4.tgz stage.commit.status FAIL
```
