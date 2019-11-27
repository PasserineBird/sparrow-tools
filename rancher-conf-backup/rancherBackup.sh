#!/bin/bash


display_usage() { 
	echo "Backup and restore script for Rancher 2.x single node install."
	echo "Must be used by a user with docker privileges and write authorization to the backup directory"
    echo "Needs tar and busybox"
    echo "Repository available at https://github.com/poignanj/sparrow-tools"
    echo ""
	echo "USAGE:"
	echo "$0 [--backup $backupDirectory | --restore $backupFile] [--slack $slack-webhook]"
    echo ""
    echo "[--slack slack-webhook] Uses slack webhook to send logs to webhook"
    echo ""
}

slack_webhook=""
backupFile=""
backupDirectory=""
RANCHER_CONTAINER_TAG=""
RANCHER_CONTAINER_NAME=""
RANCHER_VERSION=""
DATE="$(date +%Y-%m-%d)"

elog() {
    #if [ verbose == "-v" ]
    #then
        echo $@
    #fi
    if [ -n "$slack_webhook" ]
    then
        curl -X POST -H 'Content-type: application/json' --data "{'text':\"$@\"}" $slack_webhook
    fi
}
getGlobals(){
	set $(docker ps -a | grep rancher | awk 'BEGIN { FS = "(:| )+" ; OFS = " " } ; {print $1, $2, $3, $NF}')
	RANCHER_VERSION=$3
	RANCHER_CONTAINER_NAME=$4
	RANCHER_CONTAINER_TAG=$3
}
printGlobals(){
	getGlobals
	elog "$RANCHER_VERSION $RANCHER_CONTAINER_NAME $RANCHER_CONTAINER_TAG"
}
backup() {
	elog "docker stop $RANCHER_CONTAINER_NAME"
	docker stop $RANCHER_CONTAINER_NAME
	elog "docker create --volumes-from $RANCHER_CONTAINER_NAME --name rancher-data-$DATE rancher/rancher:$RANCHER_CONTAINER_TAG"
	docker create --volumes-from $RANCHER_CONTAINER_NAME --name rancher-data-$DATE rancher/rancher:$RANCHER_CONTAINER_TAG
	elog "docker run  --volumes-from rancher-data-$DATE -v $PWD:/backup:z busybox tar zcvf $backupDirectory/rancher-data-backup-$RANCHER_VERSION-$DATE.tar.gz /var/lib/rancher"
	docker run  --volumes-from "rancher-data-$DATE" -v $PWD:/backup:z busybox tar zcvf "$backupDirectory/rancher-data-backup-$RANCHER_VERSION-$DATE.tar.gz" /var/lib/rancher
	docker start $RANCHER_CONTAINER_NAME
	docker rm $(docker ps -a | grep rancher | grep -v $RANCHER_CONTAINER_NAME | awk '{print $1}')
}

restore() {
	docker stop $RANCHER_CONTAINER_NAME
	docker run  --volumes-from $RANCHER_CONTAINER_NAME -v $PWD:/backup \
		busybox sh -c "rm /var/lib/rancher/* -rf  && \
		tar zxvf $backupFile"
	docker start $RANCHER_CONTAINER_NAME
}

#main
if test $# -eq 0
then
    display_usage
    exit 1
fi

while test $# -gt 0
do
    case "$1" in
        --backup) backupDirectory=$2
                shift
            ;;
        --restore) backupFile=$2
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
        --*) echo "unknown option $1"
            ;;
        *) echo "unknown argument $1"
            ;;
    esac
    shift
done
printGlobals

if [ -n "$backupDirectory" ]
	then backup
fi
if [ -n "$backupFile" ]
	then restore
fi

exit 0