#!/bin/bash
 
display_usage() { 
	echo "Migration script to move data from MySQL and MongoDB to new servers."
	echo "Requires to disable any service that could write in the database."
	echo "This script will disable writing authorisation for any user on the database while migrations are ongoing."
    echo "IPv6 not yet supported"
    echo ""
	echo "USAGE:"
	echo "$0 [[--MySQL] | [--srcSQL IP:port] [--desSQL IP:port]] [[--MongoDB] | [--srcMongo Connection_String] [--desMongo Connection_String]] [-y] [-v] [--slack slack-webhook]"
    echo ""
	echo "MySQL:"
	echo "[--MySQL] Activate interactive mode. Script will ignore further MySQL options."
	echo "[--srcSQL IP:port] Source database server for MySQL migration."
	echo "[--desSQL IP:port] Destination database server for MySQL migration."
	echo "If missing, script will ask for the missing parts. If none are present, script will skip MySQL migration."
    echo ""
	echo "MongoDB:"
	echo "[--MongoDB] Activate interactive mode. Script will ignore further MongoDB options."
	echo "[--srcMongo IP:port] Source database server for MongoDB migration."
	echo "[--desMongo IP:port] Destination database server for MongoDB migration."
	echo "If missing, script will ask for the missing parts. If none are present, script will skip MongoDB migration."
    echo ""
    echo "[-y] Automatically skips confirmation steps."
    echo "[-v] Make everything verbose. Even dumps. Duh. Too much stuff." 
    echo ""
    echo "[--slack slack-webhook] Uses slack webhook to send logs to webhook"
}


verify_format() {
    #TODO: Verify connection string format & IP/port format
    true
}

slack_webhook=""
auto=""
verbose=""

interSQL=""
srcSQL=""
srcuSQL="root"
srcpSQL="root"
desSQL=""
desuSQL="root"
despSQL="root"
dumpSQL_file="dump_SQL_migration.sql"
startSQLM=""

interMongo=""
srcMongo=""
srcuMongo="root"
srcpMongo="root"
desMongo=""
desuMongo="root"
despMongo="root"
mongoDB_dump_dir="mongo_dump_migration"
startMongoDBM=""


elog() {
    #if [ verbose == "-v" ]
    #then
        echo $@
    #fi
    if [ ! -z "$slack-webhook" ]
    then
        curl -X POST -H 'Content-type: application/json' --data "{'text':\"$@\"}" $slack_webhook
    fi
        
}

copySQLDatabase(){

        if [ -z "$startSQLM" ]
        then
            exit 0
        fi
        start=$(date +%s)
        elog "$(date +'%Y-%m-%d-%H-%M-%S') : Starting MySQL migration"
        echo "$srcSQL --> $desSQL"

        #Flush read 
        mysql -h $srcSQL -u $srcuSQL -p$srcpSQL $verbose -e "flush tables with read lock;"

        elog "$(date +'%Y-%m-%d-%H-%M-%S') : Starting dump of $srcSQL to file $dumpSQL_file"
        mysqldump -h $srcSQL -u $srcuSQL --add-drop-database --all-databases -r$dumpSQL_file --password=$srcpSQL
        elog "$(date +'%Y-%m-%d-%H-%M-%S') : Finished dumping $srcSQL to file $dumpSQL_file"

        elog "$(date +'%Y-%m-%d-%H-%M-%S') : Starting populating $desSQL from file $dumpSQL_file"
        mysql -h $desSQL -u $desuSQL -p$despSQL $verbose < $dumpSQL_file
        elog "$(date +'%Y-%m-%d-%H-%M-%S') : Finished populating $desSQL from file $dumpSQL_file"

        #End of copy
        mysql -h $srcSQL -u $srcuSQL -p$srcpSQL $verbose -e "Unlock tables;"
        end=$(date +%s)
        elog "$(date +'%Y-%m-%d-%H-%M-%S') : Finished MySQL migration. Took $(($end - $start)) seconds."
        exit 0
}

copyMongoDataBase(){

        if [ -z "$startMongoDBM" ]
        then
            exit 0
        fi
        start=$(date +%s)
        elog "$(date +'%Y-%m-%d-%H-%M-%S') : Starting MongoDB migration"
        echo "$srcMongo --> $desMongo"

        elog "$(date +'%Y-%m-%d-%H-%M-%S') : Starting dump of $srcMongo to $mongoDB_dump_dir"
        mongodump $verbose --uri="$srcMongo" --oplog --out=$mongoDB_dump_dir
        elog "$(date +'%Y-%m-%d-%H-%M-%S') : Finished dumping $srcMongo to $mongoDB_dump_dir"

        elog "$(date +'%Y-%m-%d-%H-%M-%S') : Starting populating $desMongo from $mongoDB_dump_dir"
        mongorestore $verbose --uri="$desMongo" $mongoDB_dump_dir
        elog "$(date +'%Y-%m-%d-%H-%M-%S') : Finished populating $desMongo from $mongoDB_dump_dir"

        end=$(date +%s)
        elog "$(date +'%Y-%m-%d-%H-%M-%S') : Finished MongoDB migration. Took $(($end - $start)) seconds."
        exit 0
}



if test $# -eq 0
then
    display_usage
    exit 1
fi

while test $# -gt 0
do
    case "$1" in
        --MySQL) interSQL="true"
            ;;
        --MongoDB) interMongo="true"
            ;;
        --srcSQL) srcSQL=$2
                shift
            ;;
        --desSQL) desSQL=$2
                shift
            ;;
        --srcMongo) srcMongo=$2
                shift
            ;;
        --desMongo) desMongo=$2
                shift
            ;;
        --slack) slack_webhook=$2
                shift
            ;;
        -h) display_usage
            exit 1
            ;;
        --help) display_usage
            exit 1
            ;;
        -v) verbose="-v" 
            ;;
        --*) echo "unknown option $1"
            ;;
        *) echo "unknown argument $1"
            ;;
    esac
    shift
done


#Verifying if MySQL parameters are empty. If yes, display alert message and skip MySQL migration
if [ -z "$srcSQL" -a -z "$desSQL" -a -z "$interSQL" ]
then
    echo "No MySQL migration."
else
    mysqlVersion=$(mysql --version)
    if [ $? -ne 0 ]
    then
        echo "mysql client not accessible, check your PATH env variable or install with packet manager"
        exit 1
    else
        echo "MySQL version found."
        echo $mysqlVersion

        #TODO: Interactive mode
        if test $interSQL
        then
            read -p "Enter address of source database [127.0.0.1:3306]:" srcSQL
            srcSQL=${srcSQL:-127.0.0.1:3306}
            srcSQL=$(echo $srcSQL | cut -d: -f1)
        fi
        echo "Source is $srcSQL"
        read -p "Enter the source database login for export [root]:" srcuSQL
        srcuSQL=${srcuSQL:-root}
        read -p "password [root]:" -s srcpSQL
        srcpSQL=${srcpSQL:-root}
        mysql -h $srcSQL -u $srcuSQL -p$srcpSQL  -e "SHOW GRANTS FOR CURRENT_USER;" || {
            echo "Source MySQL database not reachable. Aborting." 1>&2
            exit 111
        }
        echo ""

        if test $interSQL
        then
            read -p "Enter address of destination database [127.0.0.1:3306]:" desSQL
            desSQL=${desSQL:-127.0.0.1:3306}
            desSQL=$(echo $desSQL | cut -d: -f1)
        fi
        echo "Destination is $desSQL"
        read -p "Enter the destination database login for import [root]:" desuSQL
        desuSQL=${desuSQL:-root}
        read -p "password [root]:" -s despSQL
        despSQL=${despSQL:-root}
        mysql -h $desSQL -u $desuSQL -p$despSQL  -e "SHOW GRANTS FOR CURRENT_USER;" || {
            echo "Destination MySQL database not reachable. Aborting." 1>&2
            exit 121
        }
        echo ""

        #TODO: "ping" both databases for authorization check

        startSQLM="true"

    fi
fi

#Verifying if MongoDB parameters are empty. If yes, display alert message and skip MongoDB migration
if [ -z "$srcMongo" -a -z "$desMongo" -a -z "$interMongo" ]
then
    echo "No MongoDB migration."
else
    mongoVersion=$(mongo --version)
    if [ $? -ne 0 ]
    then
        echo "mongo client not accessible, check your PATH env variable or install with packet manager"
        exit 1
    else
        echo "MongoDB version found."
        echo $mongoVersion
        #Interactive mode
        if test $interMongo
        then
            read -p "Enter connection string of source database [mongodb://localhost:27017/admin]:" srcMongo
            srcMongo=${srcMongo:-mongodb://localhost:27017/admin}
            echo ""
        fi
        echo "Source is $srcMongo"
        #check if login/password present in connection string
        if [[ $srcMongo =~ ^mongodb://[^:]+:[^@]+@.*$ ]]
        then
            echo "login and password included in connection string !"
        else
            echo "login and password not present in connection string..."
            read -p "Enter the source database login for export [root]:" srcuMongo
            srcuSQL=${srcuSQL:-root}
            read -p "password [root]:" -s srcpMongo
            srcpSQL=${srcpSQL:-root}
            srcMongo=`echo $srcMongo | sed -e "s/^\(mongodb:\/\/\)\(.*\)$/\1$srcuMongo:$srcpMongo@\2/g"`
        fi
        mongo "$srcMongo" --eval "db.getCollectionNames()" || {
            echo "Source MySQL database not reachable. Aborting." 1>&2
            exit 211
        }
        if test $interMongo
        then
            read -p "Enter connection string of destination database [mongodb://localhost:27017/admin]:" desMongo
            desMongo=${desMongo:-mongodb://localhost:27017/admin}
            echo ""
        fi
        echo "Detination is $desMongo"
        #check if login/password present in connection string
        if [[ $desMongo =~ ^mongodb://[^:]+:[^@]+@.*$ ]]
        then
            echo "login and password included in connection string !"
        else
            echo "login and password not present in connection string..."
            read -p "Enter the destination database login for export [root]:" srcuMongo
            srcuSQL=${srcuSQL:-root}
            read -p "password [root]:" -s srcpMongo
            srcpSQL=${srcpSQL:-root}
            srcMongo=`echo $srcMongo | sed -e "s/^\(mongodb:\/\/\)\(.*\)$/\1$srcuMongo:$srcpMongo@\2/g"`
        fi
        mongo "$desMongo" --eval "db.getCollectionNames()" || {
            echo "Source MySQL database not reachable. Aborting." 1>&2
            exit 221
        }
        #TODO: "ping" both databases for authorization check

        startMongoDBM="true"
    fi
fi

copySQLDatabase &
copyMongoDataBase &

wait
exit 0