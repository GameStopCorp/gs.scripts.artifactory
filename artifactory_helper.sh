#!/bin/bash

# param $1 -> string -> secrets bucket name
# param $2 -> string -> file name that contains the auth token
# returns  -> string -> the auth token string
function acquireArtifactoryToken {
    echo "----- Acquiring Artifactory Token -----"
    secretsBucket=$1
    fileName=$2
    
    aws s3 cp s3://$secretsBucket/$fileName $fileName --only-show-errors
    
    value="$(cat $fileName)"
    rm -f $fileName
    
    return $value
}

# param $1 -> string -> artifactory repository URL up to the folder
# param $2 -> string -> package name including the file extension
# param $3 -> string -> auth token 
# return -> int -> HTTP status code returned from the curl command
function uploadArtifact {  
    echo "----- Begin publish to Artifactory -----"
    repo="$1"
    package="$2"
    token="$3"
    url="$repo/$package"

    # input validation
    if [ ! $repo ]; then
        echo "Parameter: Repo cannot be empty"
        exit 1
    elif [ ! $package ]; then
        echo "Parameter: Package cannot be empty"
        exit 1
    elif [ ! $token ]; then
        echo "Parameter: Token cannot be empty"
        exit 1
    fi

    #upload file to Artifactory
    response=$(curl -LI -H "Authorization: Bearer $token" -T ./$package $url -o /dev/null -w '%{http_code}\n' -s)
    echo "Artifactory upload CURL response was HTTP:$response"

    #check and make sure the CURL command worked
    if [ $response -le 201 ] ; then
        echo "$package published to Artifactory Successfully"
    else
        echo "Unexpected HTTP:$response received from publish"
        echo "--- Did you forget to update the chart version number? ---"
    fi

    echo "End publish to Artifactory"

    return $response
}

# param $1 -> string -> artifactory repository URL up to the folder
# param $2 -> string -> package name including the file extension
# param $3 -> string -> local file name to download to
# param $4 -> string -> auth token 
# return -> int -> HTTP status code returned from the curl command
function downloadArtifact {
    echo "----- BEGIN download from Artifactory -----"
    repo="$1"
    package="$2"
    fileName="$3"
    token="$4"
    url="$repo/$package"

    # input validation
    if [ ! $repo ]; then
        echo "Parameter: Repo cannot be empty"
        exit 1
    elif [ ! $package ]; then
        echo "Parameter: Package cannot be empty"
        exit 1
    elif [ ! $fileName ]; then
        echo "Parameter: FileName cannot be empty"
        exit 1
    elif [ ! $token ]; then
        echo "Parameter: Token cannot be empty"
        exit 1
    fi

    echo "INFO: package = $package"

    # --location makes curl follow a redirect
    response=$(curl --location --header "Authorization: Bearer $token" --remote-name $url --output curl.log --write-out '%{http_code}\n' --silent)
    echo "Artifactory download curl response was HTTP: $response"
    
    # check and make sure the CURL command worked
    if [[ $response -le 201 ]] ; then
        echo "INFO: $package downloaded from Artifactory successfully"
    else
        echo "Unexpected HTTP:$response received from download"
        echo "--- Is this a valid version of the package? ($package) ---"
    fi
    
    echo "----- END download from Artifactory -----"
    
    return $response
}