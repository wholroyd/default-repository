#!/bin/bash

echo
echo Attempting to build the project using docker image creation
echo

# First parameter should be the docker registry orgname/username
# Assuming it's not an environment value
if [ -n "$DOCKER_USERNAME" ]
then
  echo Username used from environment DOCKER_USERNAME variable...
else
  if [ -n "$1" ]
  then
    echo Username used from script parameter...
    DOCKER_USERNAME=$1
  else
    echo Username used from whoami...
    DOCKER_USERNAME=`whoami`
  fi
fi

# Second parameter should be the docker repository name
# Assuming it's not an environment value
if [ -n "$DOCKER_REPONAME" ]
then
  echo Repository used from environment DOCKER_REPONAME variable...
else
  if [ -n "$2" ]
  then
    echo Reponame used from script parameter...
    DOCKER_REPONAME=$2
  else
    echo Reponame used from git...
    DOCKER_REPONAME=`basename $(git rev-parse --show-toplevel)`
  fi
fi

echo
echo Starting Docker login...
echo

docker login -u $DOCKER_USERNAME -p $DOCKER_PASSWORD -e $DOCKER_EMAIL

echo
echo Starting Docker build...
echo

docker build -t $DOCKER_USERNAME/$DOCKER_REPONAME:local .

echo
echo Starting image optimization/layer-merging...
echo

ID=$(docker run -d $DOCKER_USERNAME/$DOCKER_REPONAME:local /bin/bash)
docker export $ID | docker import - $DOCKER_USERNAME/$DOCKER_REPONAME:latest

echo
echo Starting Docker image push to registry...
echo

docker push -f $DOCKER_USERNAME/$DOCKER_REPONAME:latest
