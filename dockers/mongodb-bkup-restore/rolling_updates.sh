#!/bin/bash

RETENTION_NB_DAYS=7
RETENTION_NB_WEEKS=4
RETENTION_NB_MONTHS=6

if [ $availableSpace -lt $TARGET ]
then
  # get $RETENTION_NB_DAYS last files
  if [ $(ls -A /backup/daily | wc -l) -ge $RETENTION_NB_DAYS ]
  then
    mv -v $(find /backup/daily -maxdepth 1 -name '*.archive' | tail -1) /backup/weekly
    rm -v /backup/daily/*
  fi
  if [ $(ls -A /backup/weekly | wc -l) -ge $RETENTION_NB_WEEKS ]
  then
    mv -v $(find /backup/weekly -maxdepth 1 -name '*.archive' | tail -1) /backup/monthly
    rm -v /backup/weekly/*
  fi
  if [ $(ls -A /backup/monthly | wc -l) -gt $RETENTION_NB_MONTHS ]
  then
    for FILE in $(ls -A /backup/monthly | head -n `expr $(ls -A /backup/monthly | wc -l) - $RETENTION_NB_MONTHS`)
    do
      rm -v /backup/monthly/$FILE
    done
  fi

fi

