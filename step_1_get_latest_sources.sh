#!/bin/sh


r_1 () {
    echo ""
}

verify_cleanup() {
# Make sure cleanup went as expected
    if [ -d $DIRECTORY ]; then
        echo "#-------------------------------------------------------------------#"
        echo "Clean Failed"
        echo "#-------------------------------------------------------------------#"
        exit 5
    else
        echo "#-------------------------------------------------------------------#"
        echo "Cleanup complete."
        echo "#-------------------------------------------------------------------#"
    fi
}

DIRECTORY="wolfssl"
echo "#===================================================================#"
echo " Step 1: Begin"
echo "#===================================================================#"
r_1
if [ -d $DIRECTORY ]; then
    echo "#-------------------------------------------------------------------#"
    echo "Debris left over from previous release..."
    echo "Cleaning up old libraries..."
    echo "#-------------------------------------------------------------------#"
    rm -rf $DIRECTORY
    verify_cleanup
fi


git clone https://github.com/wolfssl/wolfssl.git $DIRECTORY
RESULT=$?

# test that git clone returned a 0 for success
if [ $RESULT != 0 ]; then
    echo "#===================================================================#"
    echo "Step 1: FAILED"
    echo "#===================================================================#"
    # if git clone got some of the files but not all cleanup
    if [ -d $DIRECTORY ]; then
        rm -rf $DIRECTORY
    fi
    r_1
    exit 5
else
    echo "#===================================================================#"
    echo "Step 1: SUCCESS"
    echo "#===================================================================#"
fi

r_1
r_1
r_1
r_1
exit 0
