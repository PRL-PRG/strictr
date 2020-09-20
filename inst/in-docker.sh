#!/bin/bash

DOCKER_IMAGE_NAME="prlprg/project-strictr"

script_dir="$( cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd -P )"
base_dir=$(dirname "$script_dir")
docker_working_dir="/home/rstudio/strictR"
local_working_dir="$base_dir/inst"
cmd="bash"
[ $# -gt 0 ] && cmd="$@"

docker run \
    -ti \
    --rm \
    -e ROOT=TRUE \
    -e DISABLE_AUTH=true \
    -e USERID=$(id -u) \
    -e GROUPID=$(id -g) \
    -v "$local_working_dir:$docker_working_dir" \
    -w "$docker_working_dir" \
    "$DOCKER_IMAGE_NAME" \
    $cmd

# docker run \
#     --rm \
#     -v "$local_working_dir:$docker_working_dir" \
#     "$DOCKER_IMAGE_NAME" \
#     chown -R $(id -u):$(id -g) "$docker_working_dir"
