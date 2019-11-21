# sparrow-migration-tools
<p>Various tools for migration processes</p>



## DB-migration:
<p>
Migration script to move data from MySQL and MongoDB to new servers.<br />
Requires to disable any service that could write in the database.<br />
This script will disable writing authorisation for any user on the database while migrations are ongoing.<br />
IPv6 not yet supported<br />
</p>

**USAGE:**
<br />
./DB-migration.sh [[ --MySQL ] | [ --srcSQL IP:port ] [ --desSQL IP:port ]] [[--MongoDB] | [--srcMongo Connection_String ] [ --desMongo Connection_String ]] [-y] [-v] [ --slack slack-webhook ]
<br />
MySQL:<br />
*[--MySQL]* Activate interactive mode. Script will ignore further MySQL options.<br />
*[--srcSQL IP:port]* Source database server for MySQL migration.<br />
*[--desSQL IP:port]* Destination database server for MySQL migration.<br />
If missing, script will ask for the missing parts. If none are present, script will skip MySQL migration.<br />
<br />
MongoDB:<br />
*[--MongoDB]* Activate interactive mode. Script will ignore further MongoDB options.<br />
*[--srcMongo IP:port]* Source database server for MongoDB migration.<br />
*[--desMongo IP:port]* Destination database server for MongoDB migration.<br />
If missing, script will ask for the missing parts. If none are present, script will skip MongoDB migration.<br />
<br />
*[-v]* Make everything verbose. Even dumps. Duh. Too much stuff.<br />
*[--slack slack-webhook]* Uses slack webhook to send logs to webhook<br />

## rancherBackup
<p>Backup and restore script for Rancher 2.x single node install.
Must be used by a user with docker privileges and write authorization to the backup directory
Needs tar and busybox.</p>

**USAGE:**<br />
./rancherBackup.sh *[ --backup* $backupDirectory *| --restore* $backupFile *] [ --slack* $slack-webhook *]*<br />
