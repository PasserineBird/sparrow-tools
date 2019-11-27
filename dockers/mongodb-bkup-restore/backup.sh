#!/bin/bash
[ -z "${MONGODB_STRING}" ] && { echo "=> MONGODB_STRING cannot be empty" && exit 1; }

DATE=$(date +%Y%m%d%H%M)
echo "=> Backup started at $(date "+%Y-%m-%d %H:%M:%S")"

#todo: print DBs as dumped







'''
DATABASES=${MONGODB_DATABASE:-${MONGODB_DB:-$(mysql -h "$MONGODB_HOST" -P "$MONGODB_PORT" -u "$MONGODB_USER" -p"$MONGODB_PASS" -e "SHOW DATABASES;" | tr -d "| " | grep -v Database)}}
DB_COUNTER=0
for db in ${DATABASES}
do
  if [[ "$db" != "information_schema" ]] && [[ "$db" != "performance_schema" ]] && [[ "$db" != "mysql" ]] && [[ "$db" != _* ]]
  then
    echo "==> Dumping database: $db"
    FILENAME=/backup/$DATE.$db.sql
    LATEST=/backup/latest.$db.sql.gz
    if mysqldump -h "$MONGODB_HOST" -P "$MONGODB_PORT" -u "$MONGODB_USER" -p"$MONGODB_PASS" --databases "$db" $MONGODBDUMP_OPTS > "$FILENAME"
    then
      gzip -f "$FILENAME"
      echo "==> Creating symlink to latest backup: $(basename "$FILENAME".gz)"
      rm "$LATEST" 2> /dev/null
      cd /backup && ln -s $(basename "$FILENAME".gz) $(basename "$LATEST") && cd -
      DB_COUNTER=$(( DB_COUNTER + 1 ))
    else
      rm -rf "$FILENAME"
    fi
  fi
done
'''
#TODO: "$MAKE_SPACE" == timestamp
#check with mongo if backup will take too much place
# if no space left, delete oldest saves [if older than timestamp].

#TODO: change max backup deletion by MONGODB.tar.gz instead of MYSQL
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

echo "=> Backup process finished at $(date "+%Y-%m-%d %H:%M:%S")"
