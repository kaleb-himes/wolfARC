#!/bin/sh

WORKING_DIR=`pwd`
WOLFSSL_ROOT_LOCATION="$WORKING_DIR/wolfssl"

# Change version in configure.ac AC_INIT and the WOLFSSL_LIBRARY_VERSION line
# line will be like this:
# AC_INIT([wolfssl],[3.8.0],[https://github.com/wolfssl/wolfssl/issues],[wolfssl],[http://www.wolfssl.com])
# will need to match on: " AC_INIT([wolfssl],[
# get the three characters following: " 3.8.0 "
# Argument $1 will be the new version to use.
# This argument will be passed in from Jenkins

#####################################################################
######################## Functions ##################################
#####################################################################

# Function Return 1 line
r_1(){
echo ""
}

# Function Return 2 lines
r_2(){
echo ""
echo ""
}

# Function set failure and exit
set_failure() {
    echo "#===================================================================#"
    echo "Step 2: Failed"
    echo "#===================================================================#"
    exit $1
}

# Function Get String
get_string() {
    STRING_FOUND=`grep $1 $2`
    echo "Identified the line we want to modify:"
    echo "$STRING_FOUND"
}

# Function Get Line Number
get_line_num() {
    # grep command: grep -n <String to find> <file to look in>
    #    The "-n" means also output the line number the cut is
    #    to remove everything except the line number the return
    #    format from grep is like this: "x: <line grepped for"
    #    so we cut on the first occurance of the character ":"
    #    leaving us with just the line number
    LINE_NUM=`grep -n $1 $2 | cut -f1 -d:`
    echo "Located at line #$LINE_NUM of file $2"
}

#Function get the old version
check_old_version() {
    STRING_TO_FIND="AC_INIT(\[wolfssl\],\["
    FILE_TO_LOOK_IN="$WOLFSSL_ROOT_LOCATION/configure.ac"
    OLD_VERSION=`grep $STRING_TO_FIND $FILE_TO_LOOK_IN \
                                                       | cut -f2 -d] \
                                                       | rev \
                                                       | cut -f1 -d[ \
                                                       | rev`
    if [ "$OLD_VERSION" = "$NEW_VERSION" ]; then
        echo "The old version and the new version are the same."
        echo "OLD VERSION: $OLD_VERSION"
        echo "NEW VERSION: $NEW_VERSION"
        echo "No change, aborting test"
        set_failure 5
    # ADD A CASE FOR CHECKING IF OLD VERSION GREATER THEN NEW VERSION
    # elif
    # old version = 3.8.0 and new version = 3.7.9 then fail
    else
        echo "OLD VERSION WAS:     $OLD_VERSION"
        echo "NEW VERSION WILL BE: $NEW_VERSION"
        echo "Version is updated, proceed with the release cycle"
    fi
}

# Function update configure.ac
update_configure_dot_ac() {
    STRING_TO_FIND="AC_INIT(\[wolfssl\],\["
    FILE_TO_LOOK_IN="$WOLFSSL_ROOT_LOCATION/configure.ac"

    get_string $STRING_TO_FIND $FILE_TO_LOOK_IN
    r_1
    get_line_num $STRING_TO_FIND $FILE_TO_LOOK_IN
    S_LOCATION=`echo $LINE_NUM`
    r_1

    #Replace the old version number with the new version number
    STRING_PART1="AC_INIT([wolfssl],["
    STRING_PART2=`echo $NEW_VERSION`
    STRING_PART3="],[https://github.com/wolfssl/wolfssl/issues],[wolfssl],[http://www.wolfssl.com])"
    NEW_STRING=$STRING_PART1$STRING_PART2$STRING_PART3
    echo "We will replace the line above with this line:"
    echo "$NEW_STRING"
    r_1

    # files start at line 1 not line 0 like most cases in CS iteration
    LINE_COUNT=1

    # our temporary file
    NEW_FILE="$WOLFSSL_ROOT_LOCATION/configure.ac.temp"

    # "IFS=" preserves leading white space in lines read
    # the "-r" flag preserves backslashes (\) and white space within
    # the lines read.
    while IFS= read -r data; do
        if [ $LINE_COUNT -eq 1 ]; then
            echo "Begin writing new file from old file"
            echo "New file is: $NEW_FILE"
            echo ""
            echo "$data" > $NEW_FILE
        else
            if [ $LINE_COUNT -eq $S_LOCATION ]; then
                echo "We are at the target line: $S_LOCATION"
                echo "Inserting the new string"
                echo "$NEW_STRING" >> $NEW_FILE
            else
                echo "$data" >> $NEW_FILE
            fi
        fi
        LINE_COUNT=$((LINE_COUNT+1))
    done <$FILE_TO_LOOK_IN

    echo "The new file has been created now replace configure.ac with $NEW_FILE"
    mv $NEW_FILE $WOLFSSL_ROOT_LOCATION/configure.ac
}

# Function update version.h
update_version_dot_h() {
    CURR_LOC=`pwd`
    cd $WOLFSSL_ROOT_LOCATION
    TEMP_BACKUP="wolfssl/temp-version.h"
    cp wolfssl/version.h $TEMP_BACKUP
    echo "running autoconf..."

    #store output in variables to reduce noise
    AUTOGEN=`./autogen.sh`
    CONFIGURE=`./configure`

    #check that the version was updated
    CHECK=`git diff $TEMP_BACKUP wolfssl/version.h`
    echo "CHECKING..."
    echo "$CHECK"
    RESULT=`echo "$CHECK" | grep "$NEW_VERSION"`
    LENGTH_OF_RESULT=`echo "${#RESULT}"`
    echo "LENGTH OF RESULT: $LENGTH_OF_RESULT"
    echo "#-------------------------------------------------------------------#"
    echo "version.h update complete."
    echo "#-------------------------------------------------------------------#"

    if [ $LENGTH_OF_RESULT -lt 0 ] || [ $LENGTH_OF_RESULT -eq 0 ]; then
        echo "File $WOLFSSL_ROOT_LOCATION/wolfssl/version.h unchanged."
        echo "UPDATE FAILED."
        r_1
        mv $TEMP_BACKUP "wolfssl/version.h"
        cd $CURR_LOC
        set_failure 5
    else
       echo "File $WOLFSSL_ROOT_LOCATION/wolfssl/version.h updated"
       echo "#===================================================================#"
       echo "Step 2: Success"
       echo "#===================================================================#"
       r_1
       rm $TEMP_BACKUP
    fi

    cd $CURR_LOC
}


#####################################################################
###################### End Functions ################################
#####################################################################



echo "#===================================================================#"
echo "Step 2: Begin"
echo "#===================================================================#"
NEW_VERSION=$1

if [ -z "$NEW_VERSION" ]; then
    echo "Version not set."
    echo "USAGE:      ./step_2_change_version.sh <version #>"
    r_1
    echo "EXAMPLE:    ./step_2_change_version.sh 3.8.1"
    set_failure 5
else
    echo "VERSION IS SET TO:   $NEW_VERSION"
fi

# If there is no change in version this method will abort the release cycle
echo "#-------------------------------------------------------------------#"
echo "Verifying new version is not the same as previous version"
echo "#-------------------------------------------------------------------#"
check_old_version
echo "#-------------------------------------------------------------------#"
echo "Version verification complete."
echo "#-------------------------------------------------------------------#"
r_2
# Update wolfssl/configure.ac
echo "#-------------------------------------------------------------------#"
echo "Updating configure.ac"
echo "#-------------------------------------------------------------------#"
update_configure_dot_ac
echo "#-------------------------------------------------------------------#"
echo "configure.ac update finished."
echo "#-------------------------------------------------------------------#"
r_2
# Update wolfssl/wolfssl/version.h using AutoConf
echo "#-------------------------------------------------------------------#"
echo "Updating version.h using Autoconf."
echo "#-------------------------------------------------------------------#"
update_version_dot_h
r_2
r_2
exit 0
