#!/bin/bash
#
#  This scripts builds docker provider shell bundle, docker image and pushes to specified image to docker hub or azure acr registry

set -e
set -o pipefail

image=""
imageTag=""
dockerUser=""
usage()
{
    local basename=`basename $0`
    echo
    echo "Build and publish docker image:"
    echo "$basename --image <name of docker image> "
}

parse_args()
{

 if [ $# -le 1 ]
  then
    usage
    exit 1
 fi

# Transform long options to short ones
for arg in "$@"; do
  shift
  case "$arg" in
    "--image")  set -- "$@" "-i" ;;
    "--"*)   usage ;;
    *)        set -- "$@" "$arg"
  esac
done

local OPTIND opt

while getopts 'hi:' opt; do
    case "$opt" in
      h)
      usage
        ;;

      i)
        image="$OPTARG"
        echo "image is $OPTARG"
        ;;

      ?)
        usage
        exit 1
        ;;
    esac
  done
  shift "$(($OPTIND -1))"


 if [ -z "$image" ]; then
    echo "-e invalid image. please try with valid values"
    exit 1
 fi

 # extract image tag
 imageTag=$(echo ${image} | sed "s/.*://")

 if [ -z "$imageTag" ]; then
    echo "-e invalid image. please try with valid values"
    exit 1
 fi

if [ $image = $imageTag ]; then
  echo "-e invalid image format. please try with valid values"
  exit 1
fi

#  if [ -z "$dockerUser" ]; then
#     echo "-e missing docker username. please try with valid username for the docker login"
#     exit 1
#  fi

}

build_docker_provider()
{
  echo "building docker provider shell bundle"
  cd $buildDir
  echo "trigger make to build docker build provider shell bundle"
  make
  echo "building docker provider shell bundle completed"
}

login_to_docker()
{
  echo "login to docker with provided creds"
  # sudo docker login --username=$dockerUser
  docker login
  echo "login to docker with provided creds completed"
}

build_docker_image()
{
  echo "build docker image: $image and image tage is $imageTag"
  cd $baseDir/kubernetes/linux
  
  cd stage_1_dockerbuild_jail
  docker build --file Dockerfile_stage_1 -t "halfway" --build-arg IMAGE_TAG=$imageTag  .
  cd ..

  echo "done building first stage, starting second stage"
  docker build --file Dockerfile_stage_2 -t $image --build-arg IMAGE_TAG=$imageTag  .
  echo "build docker image completed"
}

publish_docker_image()
{
  echo "publishing docker image: $image"
  docker push  $image
  echo "publishing docker image: $image done."
}

# parse and validate args
parse_args $@

currentDir=$PWD

## TODO figureout better way than this
linuxDir=$(dirname $PWD)
kubernetsDir=$(dirname $linuxDir)
baseDir=$(dirname $kubernetsDir)
buildDir=$baseDir/build/linux
dockerFileDir=$baseDir/kubernetes/linux

echo "source code base directory: $baseDir"
echo "build directory for docker provider: $buildDir"
echo "docker file directory: $dockerFileDir"

# build docker provider shell bundle
build_docker_provider

# build docker image
build_docker_image

# publish docker image
publish_docker_image

cd $currentDir


