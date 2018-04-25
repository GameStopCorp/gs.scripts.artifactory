#!/bin/bash

source ./test/artifactory_helper_tests.sh

echo -e "\n\nTesting -> acquireArtifactoryToken_happy_path"
acquireArtifactoryToken_happy_path

echo -e "\n\nTesting -> uploadArtifact_happy_path"
uploadArtifact_happy_path

echo -e "\n\nTesting -> downloadArtifact_happy_path"
downloadArtifact_happy_path
