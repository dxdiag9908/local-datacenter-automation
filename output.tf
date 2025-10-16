#############################################
# 📤 Terraform Outputs
#############################################

output "containers" {
  description = "List of containers created"
  value = [
    docker_container.web_server.name,
    docker_container.db_server.name,
    docker_container.monitor.name
  ]
}

output "network" {
  description = "Name of Docker/Podman network"
  value       = docker_network.datacenter_net.name
}

