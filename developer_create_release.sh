#!/bin/sh

#get the absolute latest
./step_1_get_latest_sources.sh

RESULT=$?
if [ $RESULT -ne 0 ]; then
    echo "STEP 1: FAIL"
    exit 5
fi

#update the version
./step_2_change_version.sh 3.8.2

RESULT=$?
if [ $RESULT -ne 0 ]; then
    echo "STEP 2: FAIL"
    exit 5
fi

./step_3_check_example_cert_and_crl_dates.sh

RESULT=$?
if [ $RESULT -ne 0 ]; then
    echo "STEP 3: FAIL"
    exit 5
fi

