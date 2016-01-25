#!/bin/sh

#get the absolute latest
./step_1_get_latest_sources.sh > /dev/null

RESULT=$?
if [ $RESULT -ne 0 ]; then
    echo "STEP 1: FAIL"
    exit 5
else
    echo "STEP 1: SUCCESS"
fi

#update the version
./step_2_change_version.sh 3.8.1 > /dev/null

RESULT=$?
if [ $RESULT -ne 0 ]; then
    echo "STEP 2: FAIL"
    exit 5
else
    echo "STEP 2: SUCCESS"
fi

