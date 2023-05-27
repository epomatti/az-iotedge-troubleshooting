#!/bin/bash

tf_output="infrastructure/output.json"

# Variables
rg_name=$(jq -r .resource_group_name $tf_output)
iothub_name=$(jq -r .iothub_name $tf_output)
iothub_hostname=$(jq -r .iothub_hostname $tf_output)
dps_name=$(jq -r .dps_name $tf_output)
root_ca_name=$(jq -r .root_ca_name $tf_output)

# Upgrade IoT Hub root authority to V2 (DigiCert)
echo "Upgrading IoT Hub [$iothub_name] root authority to V2 (DigiCert)"
az iot hub certificate root-authority set --hub-name $iothub_name --certificate-authority v2 --yes

# Create the DPS enrollment group for IoT Edge devices
echo "Creating enrollment for Edge devices"
az iot dps enrollment-group create -n $dps_name -g $rg_name \
    --root-ca-name $root_ca_name \
    --secondary-root-ca-name $root_ca_name \
    --enrollment-id "EdgeDevicesGroup" \
    --provisioning-status "enabled" \
    --reprovision-policy "reprovisionandmigratedata" \
    --iot-hubs $iothub_hostname \
    --allocation-policy "hashed" \
    --edge-enabled true \
    --tags '{ "Environment": "Staging" }' \
    --props '{ "Debug": "false" }'

# Create the DPS enrollment group for IoT Devices (non-Edge)
echo "Creating enrollment for non-Edge devices"
az iot dps enrollment-group create -n $dps_name -g $rg_name \
    --root-ca-name $root_ca_name \
    --secondary-root-ca-name $root_ca_name \
    --enrollment-id "DevicesGroup" \
    --provisioning-status "enabled" \
    --reprovision-policy "reprovisionandmigratedata" \
    --iot-hubs $iothub_hostname \
    --allocation-policy "hashed" \
    --edge-enabled false \
    --tags '{ "Environment": "Staging" }' \
    --props '{ "Debug": "false" }'
