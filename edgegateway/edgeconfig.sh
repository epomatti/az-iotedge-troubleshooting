#!/bin/bash

domain="bluefactory.local"

sudo mkdir -p /var/secrets/aziot

sudo mv azure-iot-test-only.root.ca.cert.pem /var/secrets/aziot/
sudo mv iot-edge-device-identity-edgegateway.$domain-full-chain.cert.pem /var/secrets/aziot/
sudo mv iot-edge-device-identity-edgegateway.$domain.key.pem /var/secrets/aziot/
sudo mv iot-edge-device-ca-edgeca.$domain-full-chain.cert.pem /var/secrets/aziot/
sudo mv iot-edge-device-ca-edgeca.$domain.key.pem /var/secrets/aziot/

sudo mv config.toml /etc/aziot/

sudo iotedge config apply
