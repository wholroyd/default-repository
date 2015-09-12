#!/bin/bash

function do_build {

   current=`pwd`

   echo
   echo Starting package restoration...

   # restore the nuget packages
   for dir in $(find -name 'project.json' -printf '%h\n' | sort -u)
   do
      cd $current
      cd $dir
      echo Restoring for DNX in $(pwd)
      dnx . restore
   done
   cd $current

   # restore the npm packages
   for dir in $(find -name 'package.json' -printf '%h\n' | sort -u)
   do
      cd $current
      cd $dir
      echo Restoring for NPM in $(pwd)
      npm install
      npm install -g bower
      npm install -g gulp
   done
   cd $current

   # restore the bower packages
   for dir in $(find -name '.bowerrc' -printf '%h\n' | sort -u)
   do
      cd $current
      cd $dir
      echo Restoring for Bower in $(pwd)
      bower install
   done
   cd $current

   echo
   echo Building source...

    # build using gulp
   for dir in $(find -name 'gulpfile.js' -printf '%h\n' | sort -u)
   do
      cd $current
      cd $dir
      echo Building for Gulp in $(pwd)
      gulp default
   done
   cd $current

   echo
   echo Completed build phase
   echo
}

function do_test {
   echo Test

}

function do_docker_create {

  # We expect that when this script is ran for docker image creation that
  # there are some particular settings set prior to starting, or are given
  # on the command line when invoking it.

  # Args       $1     $2         $3
  # actions.sh create {teamname} {reponame}

  echo
  echo Starting Docker image creation...

  if [ -n "$DOCKER_TEAM" ]
  then
    echo Team name used from environment DOCKER_TEAM variable...
  else
    if [ -n "$2" ]
    then
      echo Team name used from script parameter...
      DOCKER_TEAM=$2
    else
      # This assumes the Docker team name is the same as the Git team/user name
      echo Team name used from git...
      DOCKER_TEAM=`git remote show origin | grep "Fetch URL:" | sed "s#^.*/\(.*\)/\(.*\).git#\1#"`
    fi
  fi

  if [ -n "$DOCKER_REPO" ]
  then
    echo Repo name used from environment DOCKER_REPO variable...
  else
    if [ -n "$3" ]
    then
      echo Repo name used from script parameter...
      DOCKER_REPO=$3
    else
      # This assumes the Docker repo name is the same as the Git repo name
      echo Repo name used from git...
      DOCKER_REPO=`git remote show origin | grep "Fetch URL:" | sed "s#^.*/\(.*\)/\(.*\).git#\2#"`
    fi
  fi

  echo
  echo Starting image creation...

  docker build -t $DOCKER_TEAM/$DOCKER_REPO:build .

  echo
  echo Starting image optimization/layer-merging...

  # Tagged by 'latest'
  ID=$(docker run -d $DOCKER_TEAM/$DOCKER_REPO:build /bin/bash)
  docker export $ID | docker import - $DOCKER_TEAM/$DOCKER_REPO:latest

  # Tagged by git commit
  TAG=$(git rev-parse --short HEAD)
  docker export $ID | docker import - $DOCKER_TEAM/$DOCKER_REPO:$TAG

  echo
  echo Starting image and container cleanup...

  docker rm $(docker ps -l -q)
  docker rmi -f `docker images $DOCKER_TEAM/$DOCKER_REPO | grep "build" | awk 'BEGIN{FS=OFS=" "}{print $3}'`

  echo
  echo Completed creation phase
  echo
}

function do_docker_deploy {

  echo
  echo Starting Docker image deployment...

  echo
  echo Registry authentication...

  docker login -u $DOCKER_USERNAME -p $DOCKER_PASSWORD -e $DOCKER_EMAIL

  echo
  echo Registry upload...

  docker push -f $DOCKER_TEAM/$DOCKER_REPO:latest

  echo
  echo Completed deploy phase
  echo
}

function do_universe {
  do_compile
  do_test
  do_docker_create
  do_docker_deploy
}

function do_galaxy {
  do_compile
  do_test
  do_docker_create
}

case $1 in
build)
  do_build
  ;;
test)
  do_test
  ;;
create)
  do_docker_create
  ;;
deploy)
  do_docker_deploy
  ;;
universe)
  do_universe
  ;;
galaxy)
  do_galaxy
  ;;
*)
  echo ""
  echo "Usage: $0 [OPTION]"
  echo "  OPTION            Performs..."
  echo "  ----------------  ----------------------------------------------------------"
  echo "  build             ...a compilation, if required"
  echo "  test              ...all tests in order of unit, integration, and functional"
  echo "  create            ...a Docker image"
  echo "  deploy            ...a Docker image"
  echo "  "
  echo "  universe          ...in order the options: compile, test, docker, deploy"
  echo "  galaxy            ...in order the options: compile, test, docker"
  echo "  "
  ;;
esac
