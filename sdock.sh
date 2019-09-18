#!/bin/bash
# So this is one monolithic script to replace of the separate scripts
# one script to rule them all

set -e

VERSION=0.5.0
APP=ros

useage(){
    echo "sdock.sh [cmd]"
    echo " A simple docker interface script. Valid commands:"
    echo "   bash     opens a bash command line into an existing container"
    echo "   build    builds the image"
    echo "   clean    removes build artifacts that are not needed"
    echo "   help     print this message"
    echo "   nuke     nukes everything from orbit ... the only way to be sure it is clean"
    echo "   run      runs the image"
    echo "   status   shows useful info on docker status"
}

cstop(){
    WHO=$1
    docker stop ${WHO}
    docker rm ${WHO}
}

if [[ $# -lt 1 ]]; then
    useage
    exit 1
fi

CMD=$1

# if [[ ! -d "${APP}" ]]; then
#     echo ">> Creating local octoprint to store your config info from OctoPrint"
#     mkdir octoprint
# fi

if [[ ${CMD} == "run" ]]; then
    echo ">> running the image"

    DIR=`pwd`
    HOST=`uname -n`

    docker run --rm -it \
    --name ${APP} \
    --network host \
    -v ~/.ssh:/root/.ssh \
    -v ${DIR}:/root/ros \
    --env ROS_HOSTNAME=${HOST} \
    --env ROS_MASTER_URI=http://${HOST}:11311 \
    walchko/${APP}:${VERSION}

    cstop ${APP}

elif [[ ${CMD} == "bash" ]]; then
    echo ">> launching a bash command line to the container"
    docker exec -it ${APP} bash

elif [[ ${CMD} == "build" ]]; then
    echo ">> building the image"
    docker build -t walchko/${APP}:${VERSION} .
    docker images walchko/${APP}

elif [[ ${CMD} == "status" ]]; then
    docker ps
    echo "-------------------------------------------------------"
    docker images
    echo "-------------------------------------------------------"
    docker system df -v

elif [[ ${CMD} == "stop" ]]; then
    if [[ $# -ne 2 ]]; then
        echo "You must identify what name to stop"
        echo ""
        useage
        exit 1
    fi
    NAME=$2
    cstop ${NAME}

elif [[ ${CMD} == "clean" ]]; then
    echo ">> Let's clean this up"
    docker volume rm $(docker volume ls -qf dangling=true) # delete orphaned/dangling volumes
    docker rmi $(docker images -q -f dangling=true) # delete dangling/untagged images

elif [[ ${CMD} == "nuke" ]]; then
    echo ">> nuke everything ... ha ha ha!!"
    docker kill $(docker ps -q)  # kill all running containers
    docker stop $(docker ps -a -q)
    docker rm $(docker ps -a -q)
    docker system prune -a -f
    docker images prune -a
    docker volume prune -f
    docker container prune -f
    # docker rmi $(docker ps -q)
    docker rmi $(docker images -a -q) # delete all images
    docker rm $(docker ps -aq) # delete all containers

elif [[ ${CMD} == "help" ]]; then
    useage
    exit 0

else
    echo ">> Unknown command: ${CMD}"
    echo ""
    useage
    exit 1

fi
