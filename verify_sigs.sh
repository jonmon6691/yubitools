#!/usr/bin/env bash

# Check if at least a certificate and one file are provided
if [[ $# -lt 2 ]]; then
    echo "Usage: $0 <cert.pem> <file_pattern>"
    echo "Example: $0 person.pem *.txt"
    exit 1
fi

CERT=$1
shift # Remove the cert from the argument list, leaving only the files/wildcards
FILES=("$@")

# 1. Check if certificate exists
if [[ ! -f "$CERT" ]]; then
    echo "Error: Certificate not found: $CERT"
    exit 1
fi

# 2. Extract public key to a temporary variable/file to avoid repeated extraction
# We use a variable here to avoid hitting the disk repeatedly in a loop
PUB_KEY=$(openssl x509 -in "$CERT" -pubkey -noout)

echo "Starting verification against $CERT..."
echo "------------------------------------"

# 3. Iterate through all files matched by the wildcard
for FILE in "${FILES[@]}"; do
    SIG="$FILE.sig"

    # Skip .sig files themselves if the wildcard caught them
    if [[ "$FILE" == *.sig ]]; then
        continue
    fi

    echo -n "Checking $FILE: "

    if [[ ! -f "$FILE" ]]; then
        echo "FILE NOT FOUND"
        continue
    fi

    if [[ ! -f "$SIG" ]]; then
        echo "MISSING SIGNATURE ($SIG)"
        continue
    fi

    # 4. Perform Verification
    # Note: Using pkeyutl with a pre-hashed input requires the -digest flag
    openssl pkeyutl -verify -pubin -inkey <(echo "$PUB_KEY") \
        -sigfile "$SIG" \
        -in <(openssl dgst -sha512 -binary $FILE) \
        &> /dev/null

    if [[ $? -eq 0 ]]; then
        echo "VALID"
    else
        echo "INVALID/FAILURE"
    fi
done

