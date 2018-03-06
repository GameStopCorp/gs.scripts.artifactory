#!/bin/bash

source ./src/artifactory_helper.sh

function acquireArtifactoryToken_happy_path {

    local bucket="motherhen-tools-d0083-motherhensecretsbucket-8sy4gshlk0o1"
    local fileName="ArtifactoryChartsPublishAccessToken.enc"

    acquireArtifactoryToken $bucket $fileName result

    if [ ! $result ]; then
        echo "Token is null"
        exit 1
    fi
} 

function uploadArtifact_happy_path {
    
    # get token
    local bucket="motherhen-tools-d0083-motherhensecretsbucket-8sy4gshlk0o1"
    local fileName="ArtifactoryChartsPublishAccessToken.enc"
    acquireArtifactoryToken $bucket $fileName artifactoryToken
    
    # create test file
    local fileName="foo.txt"
    echo 'Hello, world.' > $fileName
    local repo="https://gme.jfrog.io/gme/artifactory-testing-local"
    local package="$fileName"
    local token="$artifactoryToken"
    
    uploadArtifact $repo $package $artifactoryToken result

    rm $fileName

    echo $result
}

function downloadArtifact_happy_path {

    local bucket="motherhen-tools-d0083-motherhensecretsbucket-8sy4gshlk0o1"
    local fileName="ArtifactoryChartsPublishAccessToken.enc"
    acquireArtifactoryToken $bucket $fileName artifactoryToken

    local repo="https://gme.jfrog.io/gme/charts"
    local package="index.yaml"
    local fileName="index.yaml"
    local token="$artifactoryToken"

    downloadArtifact $repo $package $fileName $token result

    if [ -f "$fileName" ]
    then
        echo "$fileName found."
    else
        echo "$fileName not found."
        exit 1
    fi
    
    rm $fileName

    echo $result
}
