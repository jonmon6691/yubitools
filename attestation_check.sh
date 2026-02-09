#!/usr/bin/env bash

ATT_CERT=`mktemp -t attestation_cert`
ATT_INTER=`mktemp`

ykman piv certificates export f9 $ATT_INTER
if [[ $? -ne 0 ]] ; then
	exit 1
fi

ykman piv keys attest 9c $ATT_CERT
if [[ $? -ne 0 ]] ; then
	exit 1
fi

openssl verify -verbose -show_chain \
	-trusted <(curl -s https://developers.yubico.com/PKI/yubico-ca-1.pem) \
	-trusted <(curl -s https://developers.yubico.com/PKI/yubico-intermediate.pem) \
	-untrusted $ATT_INTER \
	$ATT_CERT

if [[ $? ]]; then
	echo "VALID! - Key was generated on the device"
else
	echo "NOT VALID! - Could not confirm that key was generated on the device"
fi

rm $ATT_CERT $ATT_INTER

