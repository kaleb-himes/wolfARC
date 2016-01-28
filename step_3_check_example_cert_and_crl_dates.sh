#!/bin/sh

#####################################################################
######################## Functions ##################################
#####################################################################

# Function return twice
r_2() {
    echo ""
    echo ""
}

# Function set failure status and exit
set_failure() {
    echo "#===================================================================#"
    echo "Step 3: Failed"
    echo "#===================================================================#"
    exit $1
}

# Function assign a number based on Month
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

# Function ensure year is an integer value
verify_year() {
    TEST_AGAINST='^[0-9]+$'
    if ! [[ $1 =~ $TEST_AGAINST ]]; then
        VERIFY_YEAR=0
    else
        VERIFY_YEAR=1
    fi
}

# Function double check the year if still incorrect fail
verify_year_fail() {
    if ! [[ $1 =~ $TEST_AGAINST ]]; then
        echo "Could not correctly extract the year"
        echo "The year identified was: $CHECK_YEAR"
        set_failure 5
    fi
}

# Function process date in the line read from the grep result
process_date() {
    # Extract just the date from the line containing the "Not After" date
    E_DATE=`echo "$1" | rev | cut -f1-3 -d: | rev`

    # Extract just the month from the extracted date
    CHECK_MONTH=`echo "$E_DATE" | cut -f1-2 -d ' ' | rev | cut -f1 -d ' ' | rev`
    month_by_num $CHECK_MONTH
    CHECK_MONTH_NUM=$MONTH

    # Extract just the year from the extracted date
    CHECK_YEAR=`echo "$E_DATE" | cut -f1-5 -d ' ' | rev | cut -f1 -d ' ' | rev`

    # Due to format discrepancies we should verify we got the year
    verify_year $CHECK_YEAR
    if [ $VERIFY_YEAR -eq 0 ]; then
        echo "BAD YEAR FOUND: $CHECK_YEAR"
        CHECK_YEAR=`echo "$E_DATE" | cut -f1-6 -d ' ' | rev | cut -f1 -d ' ' \
                    | rev`
        echo "NEW CHECK_YEAR: $CHECK_YEAR"
        verify_year_fail $CHECK_YEAR
    fi
    # Process the date
    DIFF_YEAR=$(( CHECK_YEAR - NOW_YEAR ))
    DIFF_MONTH=$(( CHECK_MONTH_NUM - NOW_MONTH_NUM ))
    if [ $DIFF_YEAR -eq 0 ]; then
        if [ $DIFF_MONTH -le 4 ]; then
            echo "Certificates need to be updated"
            set_failure 5
        else
            echo "Certificate will expire in $DIFF_MONTH months"
        fi
    else
        if [ $DIFF_YEAR -lt 0 ]; then
            echo "This must be one of the expired certificates used for testing."
            echo "$1"
        else
            echo "Certificate will expire in $DIFF_YEAR year(s) and $DIFF_MONTH month(s)"
        fi
    fi
}


#####################################################################
###################### End Functions ################################
#####################################################################


echo "#===================================================================#"
echo "Step 3: Begin"
echo "#===================================================================#"

CURR_DIR=`pwd`
NOW_YEAR="$(date +'%Y')"
echo "The current year is: $NOW_YEAR"
NOW_MONTH="$(date +'%b')"
echo "The current month is: $NOW_MONTH"
month_by_num $NOW_MONTH
NOW_MONTH_NUM=$MONTH
echo "Current month in decimal format is: $NOW_MONTH_NUM"

# Extract the expiration dates for certificates
grep -r "$CURR_DIR/wolfssl/certs/" -e "Not After" | while read -r line; do
#    echo "$line"
    process_date "$line"
done

line=""

# Extract the expiration dates for crl's
grep -r "$CURR_DIR/wolfssl/certs/" -e "Next Update" | while read -r line; do
    process_date "$line"
done

echo "#===================================================================#"
echo "Step 3: Success"
echo "#===================================================================#"
r_2
r_2
exit 0
