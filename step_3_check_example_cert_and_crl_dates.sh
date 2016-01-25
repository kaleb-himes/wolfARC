#!/bin/sh

CURR_DIR=`pwd`

# Extract the expiration dates for certificates
grep -r "$CURR_DIR/wolfssl/certs/" -e "Not After.*" | while read -r line; do
#    echo "PROCESSING:"
#    echo "$line"
    E_DATE=`echo "$line" | rev | cut -f1-3 -d: | rev`
    echo "EXTRACTED DATE IS: $E_DATE"
done

# Extract the expiration dates for crl's
grep -r "$CURR_DIR/wolfssl/certs/" -e "Next Update" | while read -r line; do
#    echo "PROCESSING:"
#    echo "$line"
    E_DATE=`echo "$line" | rev | cut -f1-3 -d: | rev`
    echo "EXTRACTED DATE IS: $E_DATE"
done
