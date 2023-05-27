#!/bin/bash

sudo mkdir /var/secrets
sudo mkdir /var/secrets/aziot

sudo mv azure-iot-test-only.root.ca.cert.pem /var/secrets/aziot/
sudo mv iot-edge-device-identity-edgegateway.fusiontech.iot-full-chain.cert.pem /var/secrets/aziot/
sudo mv iot-edge-device-identity-edgegateway.fusiontech.iot.key.pem /var/secrets/aziot/
sudo mv iot-edge-device-ca-edgeca.fusiontech.iot-full-chain.cert.pem /var/secrets/aziot/
sudo mv iot-edge-device-ca-edgeca.fusiontech.iot.key.pem /var/secrets/aziot/

sudo mv config.toml /etc/aziot/

sudo iotedge config apply
