#!/bin/bash

[ -z "${MONGODB_STRING}" ] && { echo "=> MONGODB_STRING cannot be empty" && exit 1; }



DATE=$(date +%Y%m%d%H%M)
echo "=> Backup started at $(date "+%Y-%m-%d %H:%M:%S")"
FILENAME="/backup/daily/${DATE}_mongodb_backup.archive"

data=$(mongo --quiet "${MONGODB_STRING}" --eval "db.adminCommand( { listDatabases: 1 } )" | grep -v "$(date +%Y-%m-%d)")
totalSize=$(echo $data | jq .totalSize)
availableSpace=`df /backup | tail -1 | awk '{print $4}'`
echo "Estimated dump size: $totalSize bytes"
echo "Space available: $availableSpace bytes"

/rolling_updates.sh

#TODO: TRANSFORMER MONGO_STRING INTO ENVS -> IN RUN.SH

mongodump --quiet -h "$MONGO_HOST" -u "$MONGO_USER" -p "$MONGO_PASSWD" -d "$MONGO_DB" --authenticationDatabase="$MONGO_AUTH_DB" --archive=$FILENAME


if [ -n "$MAX_BACKUPS" ]
then
  MAX_FILES=$(( MAX_BACKUPS * DB_COUNTER ))
  while [ "$(find /backup -maxdepth 1 -name "*.archive" -type f | wc -l)" -gt "$MAX_FILES" ]
  do
    TARGET=$(find /backup -maxdepth 1 -name "*.archive" -type f | sort | head -n 1)
    echo "==> Max number of backups ($MAX_BACKUPS) reached. Deleting ${TARGET} ..."
    rm -rf "${TARGET}"
    echo "==> Backup ${TARGET} deleted"
  done
fi

echo "=> Backup process finished at $(date "+%Y-%m-%d %H:%M:%S")"
