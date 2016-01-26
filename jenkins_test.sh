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
./step_2_change_version.sh 3.8.2 > /dev/null

RESULT=$?
if [ $RESULT -ne 0 ]; then
    echo "STEP 2: FAIL"
    exit 5
else
    echo "STEP 2: SUCCESS"
fi

./step_3_check_example_cert_and_crl_dates.sh > /dev/null

RESULT=$?
if [ $RESULT -ne 0 ]; then
    echo "STEP 3: FAIL"
    exit 5
else
    echo "STEP 3: SUCCESS"
fi

