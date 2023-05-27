#!/bin/bash

output=$(openssl x509 -in ./openssl/certs/iot-edge-device-identity-edgegateway.bluefactory.local.cert.pem -fingerprint -noout -nocert)
echo $output

output=$(sed "s/SHA1 Fingerprint=//g" <<<"$output")
echo $output

thumbprint=$(sed "s/://g" <<<"$output")
echo $thumbprint

echo "Registring EdgeGateway device..."

az iot hub device-identity create \
    --device-id EdgeGateway \
    --hub-name "iot-bluefactory" \
    --edge-enabled \
    --auth-method x509_thumbprint \
    --primary-thumbprint $thumbprint \
    --secondary-thumbprint $thumbprint
