#!/bin/bash
[ -z "${MONGODB_STRING}" ] && { echo "=> MONGODB_STRING cannot be empty" && exit 1; }
#[ -z "${MONGODB_FILE}" ] && { echo "=> MONGODB_FILE cannot be empty" && exit 1; }



if [ "$#" -ne 1 ]
then
    echo "You must pass the path of the backup file to restore"
fi

echo "=> Restore database from $1"
set -o pipefail
if mongorestore -h "$MONGO_HOST" -u "$MONGO_USER" -p "$MONGO_PASSWD" --authenticationDatabase="$MONGO_AUTH_DB" --archive=$1
then
    echo "=> Restore succeeded"
else
    echo "=> Restore failed"
fi
