#!/bin/bash

# build moltres container
docker build -t moltres -f moltres.dockerfile . 

# Start postgresql container
if [ ! "$(docker ps -a -q -f name=postgres)" ] 
then
    echo "starting postgres container..."
    docker run --name postgres \
        -e POSTGRES_PASSWORD=postgres \
        -p 5432:5432 \
        -d \
        --rm \
        postgres
else
    echo "postgres container already started..."
fi

# Start phoenix container
if [ ! "$(docker ps -a -q -f name=merlin)" ]; then
    echo "starting phoenix container..."
    docker run -itd --name merlin \
        -p 4000:4000 \
        -v ~/dev/merlin/work:/home/merlin/work \
        moltres
else
    if [ "$(docker ps -aq -f status=exited -f name=merlin)" ]; then
        echo "restarting phoenix container..."
        docker start merlin
    else
        echo "phoenix container already started..."
    fi
fi
