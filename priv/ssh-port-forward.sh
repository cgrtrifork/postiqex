#!/bin/bash

# https://unix.stackexchange.com/a/248319
function ephemeral_port() {
    read LOWERPORT UPPERPORT < /proc/sys/net/ipv4/ip_local_port_range
    PORT=""
    while :
    do
        PORT="`shuf -i $LOWERPORT-$UPPERPORT -n 1`"
        ss -lpn | grep -q ":$PORT " || break
    done
    echo $PORT
}

if [ $# -ne 4 ]; then
    echo "Expected 4 arguments: REMOTE_USER REMOTE_HOST REMOTE_PORT PKEY_PATH" && exit 1;
fi

REMOTE_USER=$1
REMOTE_HOST=$2
REMOTE_PORT=$3
PKEY_PATH=$4

HASH=$(echo "127.0.0.1${REMOTE_HOST}${REMOTE_PORT}${REMOTE_USER}" | shasum | cut -f1 -d" ")
SOCKET_PATH=/tmp/postiqex-socket-${HASH}

ssh -i ${PKEY_PATH} -fMNS ${SOCKET_PATH} ${REMOTE_USER}@${REMOTE_HOST} || exit 1; 

while :
do 
    LOCAL_PORT=$(ephemeral_port);
    ssh -S ${SOCKET_PATH} -O forward -L 127.0.0.1:${LOCAL_PORT}:localhost:${REMOTE_PORT} ${HASH} && break;
done

echo "{\"port\":\"${LOCAL_PORT}\",\"socket\":\"${SOCKET_PATH}\",\"id\":\"${HASH}\"}"