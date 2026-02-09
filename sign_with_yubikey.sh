#!/usr/bin/env bash

INFILE=$1
OUTFILE=$1.sig

if [ ! -f $INFILE ]; then
	echo Error: $INFILE is not a file
	exit 1
fi

yubico-piv-tool -a verify-pin --sign -s 9c -A ED25519 -i <(openssl dgst -sha512 -binary $INFILE) -o $OUTFILE

