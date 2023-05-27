output "edgegateway_ssh_command" {
  value = "ssh edgegateway@${module.edgegateway.public_ip}"
}
