#!/bin/bash

# Define the sys and port environment variables based on the provided conditions
if [ "$1" = "msn" ]; then
    sys="msn"
    port="8889"
elif [ "$1" = "mx" ]; then
    sys="mx"
    port="8888"
else
    echo "Invalid argument. Usage: $0 [msn/mx]"
    exit 1
fi

# Function to stop Docker Compose containers gracefully
function stop_containers() {
    cd ..
    docker compose down
    cd ./scripts
    exit 0
}

# Function to start the MSN containers using Docker Compose
function start_msn_containers() {
    cd ..
    docker compose down
    docker compose build
    docker compose up -d \
        dashboard \
        msn-api \
        msn-data-1 \
        msn-data-2 \
        msn-data-3 \
        msn-data-4 \
        msn-data-5 \
        msn-data-6
    cd ./scripts
}

# Function to start the MX containers using Docker Compose
function start_mx_containers() {
    cd ..
    docker compose down
    docker compose build
    trap 'stop_containers' SIGINT
    docker compose up -d \
        dashboard \
        cpe \
        mx-api \
        mx-data-1 \
        mx-data-2 \
        mx-data-3 \
        mx-data-4
    cd ./scripts
}

# Start the appropriate containers based on the environment variables
if [ "$sys" = "msn" ]; then
    start_msn_containers
elif [ "$sys" = "mx" ]; then
    start_mx_containers

# Run the Python websockets script based on the sys and port environment variables
if [ "$sys" = "msn" ]; then
    python -m websockets ws://127.0.0.1:${port}
elif [ "$sys" = "mx" ]; then
    python -m websockets ws://127.0.0.1:1000/${sys}-controller
else
    echo "Invalid argument. Usage: $0 [msn/mx]"
    exit 1
fi
