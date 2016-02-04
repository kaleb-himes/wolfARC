#!/bin/sh

NEW_VERSION=$1
if [ -z "$NEW_VERSION" ]; then
    echo "Version not set."
    echo "USAGE:      ./step_2_change_version.sh <version #>"
    r_1
    echo "EXAMPLE:    ./step_2_change_version.sh 3.8.1"
    set_failure 5
fi

#get the absolute latest
./step_1_get_latest_sources.sh

RESULT=$?
if [ $RESULT -ne 0 ]; then
    echo "STEP 1: FAIL"
    exit 5
fi

#update the version
./step_2_change_version.sh $1

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

./step_4_update_readme.sh $1

if [ $RESULT -ne 0 ]; then
    echo "STEP 4: FAIL"
    exit 5
fi
