# gs.scripts.artifactory

This repository contains some helper scripts that will facilitate interaction with Artifactory.

## Usage

To download a key:

```bash
source /gs.scripts.artifactory/src/artifactory_helper.sh
acquireArtifactoryToken bucket-name keyname $result
echo $result
```
