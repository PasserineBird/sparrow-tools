#!/bin/bash
[ -z "${MONGODB_USER}" ] && { echo "=> MONGODB_USER cannot be empty" && exit 1; }
[ -z "${MONGODB_PASS}" ] && { echo "=> MONGODB_PASS cannot be empty" && exit 1; }

if [ "$#" -ne 1 ]
then
    echo "You must pass the path of the backup file to restore"
fi

echo "=> Restore database from $1"
set -o pipefail
if gunzip --stdout "$1" | mysql -h "$MONGODB_HOST" -P "$MONGODB_PORT" -u "$MONGODB_USER" -p"$MONGODB_PASS"
then
    echo "=> Restore succeeded"
else
    echo "=> Restore failed"
fi
