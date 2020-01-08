#!/bin/bash
touch /mongodb_backup.log
tail -F /mongodb_backup.log &

if [ "${INIT_BACKUP}" -gt "0" ]; then
  echo "=> Create a backup on the startup"
  /backup.sh
elif [ -n "${INIT_RESTORE_LATEST}" ]; then
  echo "=> Restore latest backup" 
  find /backup -maxdepth 1 -name '*.archive' | tail -1 | xargs /restore.sh
fi

echo "${CRON_TIME} /backup.sh >> /mongodb_backup.log 2>&1" > /crontab.conf
crontab /crontab.conf
echo "=> Running cron task manager"
exec crond -f
