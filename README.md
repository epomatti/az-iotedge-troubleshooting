# Azure IoT Edge Troubleshooting

Troubleshooting IoT Edge connectivity and configuration.

<img src=".assets/tshoot.png" width=550 />

## 1 - Infrastructure

Generate the certificate chain:

```sh
bash scripts/generateCerts.sh
```

Create the infrastructure:

```sh
terraform -chdir="infra" init
terraform -chdir="infra" apply -auto-approve
```

<details>
  <summary>(Optional) Upgrade IoT Hub certificate to V2</summary>
  
  Migrate the IoT Hub to use DigiCert G2 root:
  
  ```sh
  az iot hub certificate root-authority set --hub-name "iot-bluefactory" --certificate-authority v2 --yes
  ```
</details>

Make sure the EdgeGateway has completed the installation:

```sh
# Connect to the IoT Edge VM
ssh edgegateway@<public-ip>

# Check if the cloud-init status is "done", otherwise wait with "--wait"
cloud-init status

# Confirm that the IoT Edge runtime has been installed
iotedge --version
```

Restart the VM to activate any Linux kernel updates:

```sh
az vm restart -n "vm-bluefactory-edgegateway" -g "rg-bluefactory"
```

### 5 - Register the IoT Edge device:

> ⚠️ IoT Hub allows only IoT Edge devices with self-signed (thumbprint) method. For CA-Signed, you [must use Device Provisioning Service](https://github.com/MicrosoftDocs/azure-docs/issues/108363).

```sh
bash bash scripts/registerEdgeGatewayDevice.sh
```

### 6 - Upload Edge config

This will upload the required files to the EdgeGateway:

```
bash scripts/uploadEdgeConfig.sh
```

### 7 - Run the config in the EdgeGateway

Connect to the EdgeGateway and complete the configuration:

```sh
# Run via SSH
sudo bash edgeconfig.sh

# Verify the results
sudo iotedge system status
sudo iotedge system logs
sudo iotedge check
```

### 8 - Deploy the modules

Trigger the first module deployment:

```sh
az iot edge deployment create --deployment-id "gateway" \
    --hub-name $(jq -r .iothub_name infra/output.json) \
    --content "@edgegateway/deployments/gateway.json" \
    --labels '{"Release":"001"}' \
    --target-condition "deviceId='EdgeGateway'" \
    --priority 10
```

Check the portal and the IoT device:

```sh
# List the modules in the Azure VM
iotedge list
```
