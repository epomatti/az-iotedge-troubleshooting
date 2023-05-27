#!/bin/bash

##### Setup #####

output_file="infra/output.json"

# IoT Edge
remote_edgegateway_ip=$(jq -r .edgegateway_ip $output_file)
echo "Edge Gateway VM public IP: $remote_edgegateway_ip"
remote_target_dir="/home/edgegateway/"

# Provisioning Service
iothub_hostname=$(jq -r .iothub_hostname $output_file)

# Secrets
local_certs="openssl/certs"
local_private_keys="openssl/private"

# Domain
domain="bluefactory.local"
device_id="EdgeGateway"

##### Copy #####

# Secrets
scp "$local_certs/azure-iot-test-only.root.ca.cert.pem" "edgegateway@$remote_edgegateway_ip:$remote_target_dir"
scp "$local_certs/iot-edge-device-identity-edgegateway.$domain-full-chain.cert.pem" "edgegateway@$remote_edgegateway_ip:$remote_target_dir"
scp "$local_private_keys/iot-edge-device-identity-edgegateway.$domain.key.pem" "edgegateway@$remote_edgegateway_ip:$remote_target_dir"
scp "$local_certs/iot-edge-device-ca-edgeca.$domain-full-chain.cert.pem" "edgegateway@$remote_edgegateway_ip:$remote_target_dir"
scp "$local_private_keys/iot-edge-device-ca-edgeca.$domain.key.pem" "edgegateway@$remote_edgegateway_ip:$remote_target_dir"

# IoT Edge
rm -f edgegateway/config.toml

cp edgegateway/config-template.toml edgegateway/config.toml
sed -i "s/IOTHUB_HOSTNAME/$iothub_hostname/g" edgegateway/config.toml
sed -i "s/DEVICE_ID/$device_id/g" edgegateway/config.toml
scp edgegateway/config.toml "edgegateway@$remote_edgegateway_ip:$remote_target_dir"
scp edgegateway/edgeConfig.sh "edgegateway@$remote_edgegateway_ip:$remote_target_dir"
