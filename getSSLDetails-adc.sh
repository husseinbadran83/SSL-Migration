#!/bin/bash



##set -x



# Configuration

NSIP="$1"  # Change this to your actual Netscaler IP

USERNAME="$2"

PASSWORD="$3"

SSL_NAME="$4"



# Function to print script usage

usage() {

    echo "Usage: $0 <COMMON_NAME>"

    exit 1

}



# Check if COMMON_NAME is provided

if [ -z "$SSL_NAME" ]; then

    usage

fi



# Log in to NetScaler

echo "Searching for SSL certificate with name: $SSL_NAME"

# Fetch search results

RESPONSE=$(curl -X GET -H "Authorization: Basic $(echo -n "$USERNAME:$PASSWORD" | base64)" -s "http://${NSIP}/nitro/v1/config/sslcertkey/${SSL_NAME}" \

                -H "Content-Type: application/json" -H "Accept: application/json")







# Check if the response is not empty

if [ -z "$RESPONSE" ]; then

    echo "SSL certificate '${CERT_NAME}' not found."

    exit 1

fi





CERTIFICATE_DETAILS=$(echo "$RESPONSE" | jq --arg SSL_NAME "$SSL_NAME" '.sslcertkey[] | select(.certkey)')





CERT_NAME=$(echo $CERTIFICATE_DETAILS | jq -r '.certkey')

PRIVATE_KEY=$(echo $CERTIFICATE_DETAILS | jq -r '.key')

PUBLIC_KEY=$(echo $CERTIFICATE_DETAILS | jq -r '.cert')





# Print the certificate details

echo "Certificate Name: $CERT_NAME"

echo "Public Key File: $PUBLIC_KEY"

echo "Private Key File: $PRIVATE_KEY"





echo $CERT_NAME,$PUBLIC_KEY,$PRIVATE_KEY > ADC_SSL_DETAILS.csv



