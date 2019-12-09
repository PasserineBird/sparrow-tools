#!/bin/bash

[ -z "${MONGODB_STRING}" ] && { echo "=> MONGODB_STRING cannot be empty" && exit 1; }



DATE=$(date +%Y%m%d%H%M)
echo "=> Backup started at $(date "+%Y-%m-%d %H:%M:%S")"
FILENAME="/backup/${DATE}_mongodb_backup.archive"

data=$(mongo --quiet "${MONGODB_STRING}" --eval "db.adminCommand( { listDatabases: 1 } )" | grep -v "$(date +%Y-%m-%d)")
totalSize=$(echo $data | jq .totalSize)
echo "Estimated dump size: $totalSize bytes"

mongodump -uri="$MONGODB_STRING" --archive=$DIRNAME


#TODO: "$MAKE_SPACE" == timestamp
#check with mongo if backup will take too much place
# if no space left, delete oldest saves [if older than timestamp].

#TODO: change max backup deletion by MONGODB.tar.gz instead of MYSQL

'''
if [ -n "$MAX_BACKUPS" ]
then
  MAX_FILES=$(( MAX_BACKUPS * DB_COUNTER ))
  while [ "$(find /backup -maxdepth 1 -name "*.sql.gz" -type f | wc -l)" -gt "$MAX_FILES" ]
  do
    TARGET=$(find /backup -maxdepth 1 -name "*.sql.gz" -type f | sort | head -n 1)
    echo "==> Max number of backups ($MAX_BACKUPS) reached. Deleting ${TARGET} ..."
    rm -rf "${TARGET}"
    echo "==> Backup ${TARGET} deleted"
  done
fi
'''
echo "=> Backup process finished at $(date "+%Y-%m-%d %H:%M:%S")"
