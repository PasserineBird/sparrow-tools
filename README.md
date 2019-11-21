# sparrow-migration-tools

Various tools for migration processes

## DB-migration

 * Migration script to move data from MySQL and MongoDB to new servers.
 * Requires to disable any service that could write in the database.
 * This script will disable writing authorisation for any user on the database while migrations are ongoing.
 * IPv6 not yet supported


### Usage

`./DB-migration.sh [[ --MySQL ] | [ --srcSQL IP:port ] [ --desSQL IP:port ]] [[ --MongoDB ] | [ --srcMongo Connection_String ] [ --desMongo Connection_String ]] [ -y ] [ -v ] [ --slack slack-webhook ]`

#### MySQL

 * `[ --MySQL ]` Activate interactive mode. Script will ignore further MySQL options.
 * `[ --srcSQL IP:port ]` Source database server for MySQL migration.
 * `[ --desSQL IP:port ]` Destination database server for MySQL migration.

If missing, script will ask for the missing parts. If none are present, script will skip MySQL migration.

#### MongoDB
 * `[ --MongoDB ]` Activate interactive mode. Script will ignore further MongoDB options.
 * `[ --srcMongo IP:port ]` Source database server for MongoDB migration.
 * `[ --desMongo IP:port ]` Destination database server for MongoDB migration.

If missing, script will ask for the missing parts. If none are present, script will skip MongoDB migration.

 * `[ -v ]` Make everything verbose. Even dumps. Duh. Too much stuff.
 * `[ --slack slack-webhook ]` Uses slack webhook to send logs to webhook.

## rancherBackup

Backup and restore script for Rancher 2.x single node install.
Must be used by a user with docker privileges and write authorization to the backup directory
Needs `tar` and `busybox`.

### Usage

`./rancherBackup.sh [ --backup $backupDirectory | --restore $backupFile ] [ --slack $slack-webhook ]`
