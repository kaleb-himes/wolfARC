#!/bin/sh

#####################################################################
######################## Functions ##################################
#####################################################################

# Function return twice
r_2() {
    echo ""
    echo ""
}

contains() {
    string="$1"

    #test for MERGE
    substring1="Merge pull request"
    if test "${string#*$substring1}" != "$string"; then
        DO_ADD=0    # $substring is in $string
    else
        DO_ADD=1    # $substring is not in $string
    fi

    # test for comment
    substring2="comment"
    if [ $DO_ADD -eq 1 ]; then
        if test "${string#*$substring2}" != "$string"; then
            DO_ADD=0    # $substring is in $string
        else
            DO_ADD=1    # $substring is not in $string
        fi
    fi
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

add_new_comments() {

    TODAY=`date +"%m/%d/%y"`
    echo "********* wolfSSL (Formerly CyaSSL) Release ${NEW_VERSION} ($TODAY)" >> ${1}
    echo "" >> ${1}
    echo "Release ${NEW_VERSION} of wolfSSL has bug fixes and new features including:" >> ${1}
    echo "" >> ${1}

    # Get the last tag (should be the most recent release)
    cd wolfssl/
    GIT_TAG=`git for-each-ref refs/tags --sort=-taggerdate --format='%(refname)' --count=1`

    GIT_TAG=`echo "$GIT_TAG" | rev | cut -f1 -d/ | rev`
    echo "GIT_TAG = $GIT_TAG"

    #AUTHORS="toddouska\|John Safranek\|David Gharske\|Jacob Barthelmeh\|kaleb-himes ..."
    #leave AUTHORS black to get everyone otherwise limit to subset of authors.
    AUTHORS=""

    git log --pretty=format:"%s" $GIT_TAG..HEAD --author="${AUTHORS}" > ${CURR_DIR}/git_log.txt

    #clean up the log and output to README
    while IFS= read -r new_line; do

        contains "$new_line"

        if [ $DO_ADD -eq 1 ]; then
            new_line="- ${new_line}"
            #get the length of the line
            LENGTH=`expr "${new_line}" : '.*'`
            if [ $LENGTH -lt 70 ]; then
                echo "$new_line" >> ${1}
            fi
        fi
    done < "${CURR_DIR}/git_log.txt"
    echo "" >> "${TEMP_OUT_1}"
    echo "" >> "${TEMP_OUT_1}"
    cd ../
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
NEW_VERSION=$1

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
    COUNT=1
    while IFS= read -r line; do
        if [ $START -eq 1 ]; then
            echo "$line" > "${TEMP_OUT_1}"
            START=0
        else
            if [ $COUNT -eq $LINE_NUM ]; then
                add_new_comments ${TEMP_OUT_1}
            fi
            echo "$line" >> "${TEMP_OUT_1}"
        fi
        COUNT=$(( COUNT + 1))
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

