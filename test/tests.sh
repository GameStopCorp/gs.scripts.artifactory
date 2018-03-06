#!/bin/bash

source ./test/artifactory_helper_tests.sh

echo "Testing -> acquireArtifactoryToken_happy_path"
acquireArtifactoryToken_happy_path

echo "Testing -> uploadArtifact_happy_path"
uploadArtifact_happy_path

echo "Testing -> downloadArtifact_happy_path"
downloadArtifact_happy_path
