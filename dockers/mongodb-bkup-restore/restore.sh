#!/bin/bash
[ -z "${MONGODB_STRING}" ] && { echo "=> MONGODB_STRING cannot be empty" && exit 1; }
[ -z "${MONGODB_FILE}" ] && { echo "=> MONGODB_FILE cannot be empty" && exit 1; }



if [ "$#" -ne 1 ]
then
    echo "You must pass the path of the backup file to restore"
fi

echo "=> Restore database from $1"
set -o pipefail
if mongorestore --uri="$MONGODB_STRING" --archive=/backup/$MONGODB_FILE
then
    echo "=> Restore succeeded"
else
    echo "=> Restore failed"
fi
