#!/bin/bash

# Set default values for the sys, deploy_containers, and websocket_path variables
sys=""
deploy_containers=false
websocket_path=""
port=""


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
    sudo docker compose down
    sudo docker compose build
    trap 'stop_containers' SIGINT
    sudo docker compose up -d \
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
    sudo docker compose down
    sudo docker compose build
    trap 'stop_containers' SIGINT
    sudo docker compose up -d \
        dashboard \
        cpe \
        mx-api \
        mx-data-1 \
        mx-data-2 \
        mx-data-3 \
        mx-data-4
    cd ./scripts
}

# Help message function
function usage() {
    echo "Usage: $0 [-s msn/mx] [-d] [-p check/ctrl/dash]" >&2
    echo "-s:   Which Mission System <msn|mx>"
    echo "-d:   Deploy Containers"
    echo "-p:   Which websocket to open (none if omitted) <check|ctrl|dash>"
    exit 1
}

# Parse the command-line options using getopts
while getopts ":s:dcp:" opt; do
    case $opt in
        s)
            sys="$OPTARG"
            ;;
        d)
            deploy_containers=true
            ;;
        p)
            websocket_path="$OPTARG"
            ;;
        c)
            cd ..
            sudo docker compose logs cpe -f
            cd ./scripts
            exit 0
            ;;
        \?)
            echo "Invalid option: -$OPTARG" >&2
            usage
            ;;
        h)
            usage
            ;;
        :)
            echo "Option -$OPTARG requires an argument." >&2
            usage
            ;;
        *)
            echo "Invalid websocket path." >&2
            usage
            ;;
    esac
done

# Validate sys and set port
case $sys in
        msn)
            port=8889
            ;;
        mx)
            port=8888
            ;;
        *)
            echo "Invalid system argument." >&2
            usage
            ;;
    esac

# Handle deploy_containers flag
if [ "$deploy_containers" = true ]; then
    if [ "$sys" = "msn" ]; then
        start_msn_containers
    elif [ "$sys" = "mx" ]; then
        start_mx_containers
    fi
fi

# Validate the websocket_path argument
if [ "$websocket_path" != "check" ] && [ "$websocket_path" != "ctrl" ] && [ "$websocket_path" != "dash" ] && [ "$websocket_path" != "" ]; then
    echo "invalid path selected"
    usage
fi



# Validate and construct the websocket URI
base_path="ws://${sys}-api:${port}"
case $websocket_path in
    check)
        python -m websockets "${base_path}/check-in"
        ;;
    ctrl)
        python -m websockets "${base_path}/${sys}-controller"
        ;;
    dash)
        python -m websockets "${base_path}/${sys}-dashboard"
        ;;
    *)
        exit 0
        ;;
esac
