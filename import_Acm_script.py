import argparse

import boto3

import sys

import logging



# Configure logging

logging.basicConfig(level=logging.INFO,

                    format='%(asctime)s - %(levelname)s - %(message)s',

                    handlers=[

                        logging.FileHandler("acm_import.log"),

                        logging.StreamHandler()

                    ])



def read_file(file_path):

    """Read the content of a file."""

    try:

        with open(file_path, 'r') as file:

            return file.read()

    except Exception as e:

        logging.error(f"Error reading file {file_path}: {e}")

        sys.exit(1)



def certificate_exists(acm_client, certificate):

    """Check if a certificate with the same details already exists in ACM."""

    try:

        response = acm_client.list_certificates(CertificateStatuses=['ISSUED'])

        for cert in response['CertificateSummaryList']:

            cert_details = acm_client.get_certificate(CertificateArn=cert['CertificateArn'])

            if cert_details['Certificate'] == certificate:

                return cert['CertificateArn']

        return None

    except Exception as e:

        logging.error(f"Error checking for existing certificate: {e}")

        sys.exit(1)



def import_certificate(certificate_path, private_key_path, certificate_chain_path=None):

    """Import a certificate into AWS ACM."""

    # Read the certificate and private key files

    certificate = read_file(certificate_path)

    private_key = read_file(private_key_path)

    certificate_chain = read_file(certificate_chain_path) if certificate_chain_path else None



    # Create a boto3 client for ACM

    acm_client = boto3.client('acm')



    # Check if the certificate already exists

    existing_cert_arn = certificate_exists(acm_client, certificate)

    if existing_cert_arn:

        logging.info(f"Certificate already exists: {existing_cert_arn}")

        return



    # Construct the parameters dictionary

    params = {

        'Certificate': certificate,

        'PrivateKey': private_key

    }



    # Add CertificateChain to params if it is provided

    if certificate_chain:

        params['CertificateChain'] = certificate_chain



    try:

        # Import the certificate

        response = acm_client.import_certificate(**params)

        logging.info(f"Certificate imported successfully: {response['CertificateArn']}")

    except Exception as e:

        logging.error(f"Error importing certificate: {e}")

        sys.exit(1)



def main():

    """Main function to parse arguments and import the certificate."""

    parser = argparse.ArgumentParser(description='Import a certificate into AWS ACM.')

    parser.add_argument('--certificate', required=True, help='Path to the certificate file')

    parser.add_argument('--private-key', required=True, help='Path to the private key file')

    parser.add_argument('--certificate-chain', help='Path to the certificate chain file (optional)')



    args = parser.parse_args()



    # Log the arguments

    logging.info(f"Script arguments: certificate={args.certificate}, private_key={args.private_key}, certificate_chain={args.certificate_chain}")



    import_certificate(args.certificate, args.private_key, args.certificate_chain)



if __name__ == '__main__':

    main()

