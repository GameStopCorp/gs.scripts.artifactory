#!/bin/bash

# param $1 -> string -> secrets bucket name
# param $2 -> string -> file name that contains the auth token
# param $3 -> return var string -> the auth token string
function acquireArtifactoryToken {
    echo "----- BEGIN acquireArtifactoryToken -----"
    local secretsBucket=$1
    local fileName=$2
    local __result=$3
    local url=s3://$secretsBucket/$fileName

    # Configure aws signature v4 to get encrypted items out of a bucket
    aws configure set s3.signature_version s3v4

    aws s3 cp $url $fileName --only-show-errors
    
    artifactoryToken="$(cat $fileName)"
    rm -f $fileName
    
    eval $__result="'$artifactoryToken'"
    echo "----- END acquireArtifactoryToken -----"
}

# param $1 -> string -> artifactory repository URL up to the folder
# param $2 -> string -> package name including the file extension
# param $3 -> string -> auth token 
# param $4 -> return int -> HTTP status code returned from the curl command
function uploadArtifact {
    echo "----- BEGIN uploadArtifact -----"
    
    local repo="$1"
    local package="$2"
    local token="$3"
    local __result=$4
    local url="$repo/$package"

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

    echo "----- END uploadArtifact -----"

    eval $__result="'$response'"
}

# param $1 -> string -> artifactory repository URL up to the folder
# param $2 -> string -> package name including the file extension
# param $3 -> string -> local file name to download to
# param $4 -> string -> auth token 
# param $5 -> return int -> HTTP status code returned from the curl command
function downloadArtifact {
    echo "----- BEGIN download from Artifactory -----"
    local repo="$1"
    local package="$2"
    local fileName="$3"
    local token="$4"
    local __result=$5
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
    
    eval $__result="'$response'"
}

# param $1 -> string -> Artifactory username
# param $2 -> string -> Artifactory API key
# param $3 -> string -> Pubish target (optional)
function doArtifactoryAuth {
    echo "----- BEGIN doArtifactoryAuth -----"
    local user=$1
    local apiKey=$2
    local publishTarget=$3

    rm -f .npmrc && touch .npmrc
    rm -f nuget.config && touch nuget.config
    echo "<?xml version=\"1.0\" encoding=\"utf-8\"?>" >> nuget.config
    echo "<configuration><packageSources><clear /></packageSources></configuration>" >> nuget.config

    npm config set registry https://gme.jfrog.io/gme/api/npm/npm/
    npmToken=$(printf $user:$apiKey | base64 --wrap=0)
    npm config set '_auth' $npmToken
    npm config set 'always-auth' true

    nuget sources add -Name Artifactory \
                      -Source https://gme.jfrog.io/gme/api/nuget/nuget \
                      -UserName $user \
                      -Password $apiKey \
                      -StorePasswordInClearText \
                      -configfile nuget.config
    nuget sources remove -Name "https://www.nuget.org/api/v2/" -configfile nuget.config # Why is this getting added?!?!?!

    if [ $publishTarget ]; then
        nuget sources add -Name ArtifactoryPublish \
                          -Source $publishTarget \
                          -UserName $ARTIFACTORY_USER \
                          -Password $ARTIFACTORY_API_KEY \
                          -StorePasswordInClearText \
                          -configfile nuget.config
    fi

    echo "----- END doArtifactoryAuth -----"
}

# param $1 -> string -> filename
function publishNugetPackage {
    echo "----- BEGIN publishNugetDeployable -----"
    local user=$1
    local apiKey=$2
    local publishTarget=$3
    local filename=$4

    doArtifactoryAuth $user $apiKey $publishTarget

    nuget push $filename -Source ArtifactoryPublish -configfile nuget.config
    echo "----- END publishNugetDeployable -----"
}