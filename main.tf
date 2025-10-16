#############################################
# 🖥️ Main Terraform Configuration
# Simulated "data center" with 3 containers
#############################################

# -------------------------------
# Create a custom network
# -------------------------------
resource "docker_network" "datacenter_net" {
  name = "datacenter_network"
}

# -------------------------------
# Web Server (nginx)
# -------------------------------
resource "docker_container" "web_server" {
  name  = "web-server"
  image = "nginx:latest"
  networks_advanced {
    name = docker_network.datacenter_net.name
  }
  ports {
    internal = 80
    external = 8080
  }
}

# -------------------------------
# Database (mysql)
# -------------------------------
resource "docker_container" "db_server" {
  name  = "db-server"
  image = "mysql:8"
  env = [
    "MYSQL_ROOT_PASSWORD=terraform123",
    "MYSQL_DATABASE=demo_db"
  ]
  networks_advanced {
    name = docker_network.datacenter_net.name
  }
}

# -------------------------------
# Monitoring Node (alpine)
# -------------------------------
resource "docker_container" "monitor" {
  name  = "monitor-node"
  image = "alpine:latest"
  command = ["sh", "-c", "while true; do echo Monitoring...; sleep 5; done"]
  networks_advanced {
    name = docker_network.datacenter_net.name
  }
}

