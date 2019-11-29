# sparrow-mongo-backup
Inspired by `fradelg/docker-mysql-cron-backup`


This docker image runs mysqldump to backup your databases periodically using cron task manager. Backups are placed in `/backup` so you can mount your backup docker volume in this path.

## Usage:

```bash
docker container run -d \
       --env MONGODB_STRING="mongodb://login:password@localhost:27017/" \
       --link mongodb \
       --volume /path/to/my/backup/folder:/backup
       passerinebird/sparrow-mongo-backup
```

## Variables

- `MONGODB_STRING`: The host/ip of your mysql database.
- `CRON_TIME`: The interval of cron job to run mysqldump. `0 3 * * sun` by default, which is every Sunday at 03:00.
- `MAX_BACKUPS`: The number of backups to keep. When reaching the limit, the old backup will be discarded. No limit by default.
- `INIT_BACKUP`: If set, create a backup when the container starts.
- `INIT_RESTORE_LATEST`: If set, restores latest backup.


## Restore from a backup

See the list of backups in your running docker container, just write in your favorite terminal:

```bash
docker container exec backup ls /backup
```

To restore a database from a certain backup, simply run:

```bash
docker container exec backup /restore.sh /backup/201908060500_mongodb_backup.archive
```

