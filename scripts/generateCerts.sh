#!/bin/bash

mkdir openssl
cd openssl

curl https://raw.githubusercontent.com/Azure/iotedge/main/tools/CACertificates/certGen.sh -o certGen.sh
curl https://raw.githubusercontent.com/Azure/iotedge/main/tools/CACertificates/openssl_root_ca.cnf -o openssl_root_ca.cnf

bash ./certGen.sh create_root_and_intermediate
bash ./certGen.sh create_edge_device_identity_certificate "edgegateway.bluefactory.local"
bash ./certGen.sh create_edge_device_ca_certificate "edgeca.bluefactory.local"

# Copies the CA root for easy access in Terraform
mkdir ../infra/secrets
cp certs/azure-iot-test-only.root.ca.cert.pem ../infra/secrets/
