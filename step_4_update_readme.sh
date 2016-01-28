#!/bin/sh

#####################################################################
######################## Functions ##################################
#####################################################################

# Function return twice
r_2() {
    echo ""
    echo ""
}

set_failure() {
    echo "#===================================================================#"
    echo "Step 4: Failed"
    echo "#===================================================================#"
    exit $1
}

get_line_num_to_start_on() {

    FOUND=0

    # See step_2_change_version.sh for explenation of this grep / cut command
    # -m 1 says to get only the first result from grep
    # @arg $1: String to grep for
    # @arg $2: File to grep in
    LINE_NUM=`grep -m 1 -n $1 $2 | cut -f1 -d:`
    if [ "$LINE_NUM" = "" ]; then
        echo "Could not find the location to start"
    else
        echo "Start new comments on line #$LINE_NUM of $2"
        FOUND=1
    fi
}

#####################################################################
###################### End Functions ################################
#####################################################################


echo "#===================================================================#"
echo "Step 4: Begin"
echo "#===================================================================#"

CURR_DIR=`pwd`
README_F="${CURR_DIR}/wolfssl/README"
README_MD_F="${CURR_DIR}/wolfssl/README.md"
TEMP_OUT_1="${CURR_DIR}/README_out.txt"
TEMP_OUT_2="${CURR_DIR}/README_md_out.txt"

# The line we are identifying as the start of the previous release notes is
# as follows
# for README look for the line:
# ""********* wolfSSL"
# full line should be:
# " ********* wolfSSL (Formerly CyaSSL) Release x.x.x (MM/DD/YYYY)"
#
# for README.md look for the line:
# "# wolfSSL"
# full line should be:
# "# wolfSSL (Formerly CyaSSL) Release x.x.x (MM/DD/YYYY)"

START_1="\*\*\*\*\*\*\*\*\*[[:space:]]wolfSSL"
START_2="\#[[:space:]]wolfSSL"

get_line_num_to_start_on $START_1 $README_F

if [ $FOUND -eq 1 ]; then
    # Update README
    START=1
    while IFS= read -r line; do
        if [ $START -eq 1 ]; then
            echo "$line" > "${TEMP_OUT_1}"
            START=0
        else
            echo "$line" >> "${TEMP_OUT_1}"
        fi
    done < "${README_F}"
else
    echo "$README_F not updated"
    set_failure 5
fi

get_line_num_to_start_on $START_2 $README_MD_F

if [ $FOUND -eq 1 ]; then
    # Update README.md
    START=1
    while IFS= read -r line; do
        if [ $START -eq 1 ]; then
            echo "$line" > "${TEMP_OUT_2}"
            START=0
        else
            echo "$line" >> "${TEMP_OUT_2}"
        fi
    done < "${README_MD_F}"
else
    echo "$README_MD_F not updated"
    set_failure 5
fi

echo "#===================================================================#"
echo "Step 4: Success"
echo "#===================================================================#"
r_2
r_2
exit 0

