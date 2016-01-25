#!/bin/sh

set_failure() {
    echo "#===================================================================#"
    echo "Step 3: Failed"
    echo "#===================================================================#"
    exit $1
}

month_by_num() {
    if [ "$1" = "Jan" ]; then
        MONTH=1
    elif [ "$1" = "Feb" ]; then
        MONTH=2
    elif [ "$1" = "Mar" ]; then
        MONTH=3
    elif [ "$1" = "Apr" ]; then
        MONTH=4
    elif [ "$1" = "May" ]; then
        MONTH=5
    elif [ "$1" = "Jun" ]; then
        MONTH=6
    elif [ "$1" = "Jul" ]; then
        MONTH=7
    elif [ "$1" = "Aug" ]; then
        MONTH=8
    elif [ "$1" = "Sep" ]; then
        MONTH=9
    elif [ "$1" = "Oct" ]; then
        MONTH=10
    elif [ "$1" = "Nov" ]; then
        MONTH=11
    elif [ "$1" = "Dec" ]; then
        MONTH=12
    else
       # default case: exit with failure
       echo "Month not found."
       set_failure 5
    fi
}

CURR_DIR=`pwd`
NOW="$(date +'%b %d %H:%M:%S %Y')"
NOW_YEAR="$(date +'%Y')"
NOW_MONTH="$(date +'%b')"
echo "Todays date is:     $NOW GMT"
echo "NOW_YEAR:  $NOW_YEAR"
echo "NOW_MONTH: $NOW_MONTH"
month_by_num $NOW_MONTH
NOW_MONTH=$MONTH
echo "NOW_MONTH: $NOW_MONTH"

# Extract the expiration dates for certificates
grep -r "$CURR_DIR/wolfssl/certs/" -e "Not After.*" | while read -r line; do
    E_DATE=`echo "$line" | rev | cut -f1-3 -d: | rev`
    echo "EXTRACTED DATE IS: $E_DATE"
    MONTH=`echo "$E_DATE" | cut -f1-2 -d ' ' | rev | cut -f1 -d ' ' | rev`
    echo "MONTH = $MONTH"
    month_by_num $MONTH
    YEAR=`echo "$E_DATE" | cut -f1-5 -d ' ' | rev | cut -f1 -d ' ' | rev`
    echo "YEAR  = $YEAR"
done

# Extract the expiration dates for crl's
grep -r "$CURR_DIR/wolfssl/certs/" -e "Next Update" | while read -r line; do
    E_DATE=`echo "$line" | rev | cut -f1-3 -d: | rev`
    echo "EXTRACTED DATE IS: $E_DATE"
done


