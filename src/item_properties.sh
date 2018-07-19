#!/bin/bash
#
# Purpose: bash scripts that get/set/update properties on artifactory items
#
# NOTE: if bash supported Object-Oriented principles, this function/method would be private; 
# Instead of directly calling this function, please add a convenience method for your specific use-case.
# That way you will be less tempted/likely to modify this base method and therefore corrupt any other usages thereof.
# 
function setArtifactPropertyValue
{
    echo "INFO: ---- BEGIN setArtifactPropertyValue -----"

    # input validation
    if [[ $# -ne 5 ]]; then
        echo "ERROR: Invalid number of parameters!"
        echo "------ Usage: setArtifactPropertyValue user apiKey itemPath property value"
        exit 1
    fi

    local user=$1
    local apiKey=$2
    local itemPath=$3
    local property=$4
    local value=$5

    local baseUrl="https://gme.jfrog.io/gme/api/storage"
    echo "INFO: Attempting to add $property=$value to $itemPath"
    # NOTE: if property already exists it will automagically update it
    response=$(curl -u $user:$apiKey -X PUT $baseUrl/$itemPath?properties=$property=$value -o /dev/null -w '%{http_code}\n' -s)

    # check and make sure the CURL command worked (we will accept anything under and including 204)
    if [ $response -le 204 ]; then
        echo "INFO: Success! (property and value added to item in Artifactory)"
    elif [ $response -eq 401 ]; then # authentication troubles
        echo "ERROR: authentication failed! (please check your user and apiKey values)"
        exit 1
    elif [ $response -eq 404 ]; then # item path invalid
        echo "ERROR: item path invalid! (please check artifactory for exact path)"
        exit 1
    else
        echo "ERROR: Unexpected HTTP:$response received from property add"
        exit 1
    fi

    echo "INFO: ---- END setArtifactPropertyValue -----"

    __result="'$response'" # fix the result returned from this command to be the curl response
}

# generic convenience/uniformity method for setting a given stage's status property to an open value
# NOTE: see setArtifactStagePass/setArtifactStageFail for uniform status values
# example: setArtifactStageStatus user apiKey npm-local/@gamestop/bunyan-lambda/-/@gamestop/bunyan-lambda-2.1.4.tgz commit FAIL
function setArtifactStageStatus
{
    if [[ $# -ne 5 ]]; then
        echo "ERROR: Invalid number of parameters!"
        echo "------ Usage: setArtifactStageStatus user apiKey itemPath stage status"
        exit 1
    fi

    setArtifactPropertyValue $1 $2 $3 stage.$4.status $5
}

# convenience/uniformity method for setting a given stage's status property to PASS
# example: setArtifactStagePass user apiKey npm-local/@gamestop/bunyan-lambda/-/@gamestop/bunyan-lambda-2.1.4.tgz commit
function setArtifactStagePass
{
    if [[ $# -ne 4 ]]; then
        echo "ERROR: Invalid number of parameters!"
        echo "------ Usage: setArtifactStagePass user apiKey itemPath stage"
        exit 1
    fi

    setArtifactStageStatus $1 $2 $3 $4 PASS
}

# convenience/uniformity method for setting a given stage's status property to FAIL
# example: setArtifactStageFail user apiKey npm-local/@gamestop/bunyan-lambda/-/@gamestop/bunyan-lambda-2.1.4.tgz commit
function setArtifactStageFail
{
    if [[ $# -ne 4 ]]; then
        echo "ERROR: Invalid number of parameters!"
        echo "------ Usage: setArtifactStageFail user apiKey itemPath stage"
        exit 1
    fi

    setArtifactStageStatus $1 $2 $3 $4 FAIL
}

