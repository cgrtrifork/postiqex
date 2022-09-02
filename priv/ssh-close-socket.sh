
if [ $# -ne 2 ]; then
    echo "Expected 2 arguments: SOCKET ID" && exit 1;
fi

SOCKET=$1
ID=$2

ssh -S ${SOCKET} -O exit ${ID} || exit 1;
