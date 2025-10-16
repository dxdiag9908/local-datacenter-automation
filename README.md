🧠 Local Data Center Automation

Fully Automated Infrastructure Simulation on RHEL 9

📑 Table of Contents

Overview

Goal

Tech Stack

Target Environment

Project Structure

Implementation Progress

Health Check Script

Current Status

Issues & Troubleshooting

Results

Next Steps

Author Notes

Troubleshooting Summary

📘 Overview

This project automates the creation and configuration of a small, realistic “data center” environment — running entirely on a local RHEL 9 system.
It demonstrates a complete automation workflow using Terraform, Ansible, Bash, and optionally PowerShell.

🎯 Goal

To simulate a self-contained data center using open-source DevOps tools for provisioning, configuration management, and orchestration — all running locally, without any cloud dependencies.

🧱 Tech Stack
Tool	Purpose
Terraform	Provision and orchestrate local infrastructure
Ansible	Configure and manage services
Bash	Automate validation and workflow orchestration
PowerShell (optional)	Cross-platform status reporting
Podman (Docker CLI)	Lightweight container runtime for local “VM-like” simulation
Libvirt / QEMU-KVM	(Initial attempt) Virtualization backend for local VMs
🏗️ Target Environment
VM / Container	Role	OS	Function
web-server	Web Server	nginx:latest	Serves static web content
db-server	Database Server	mysql:8	Backend data services
monitor-node	Monitoring Node	alpine:latest	Simulated system metrics collection
📂 Project Structure
local-datacenter-automation/
├── terraform/
│   ├── main.tf
│   ├── provider.tf
│   ├── output.tf
│   └── .gitignore
│
├── ansible/
│   ├── inventory.ini
│   ├── playbooks/
│   │   ├── webserver.yml
│   │   ├── database.yml
│   │   └── monitoring.yml
│   └── roles/
│       ├── web/
│       ├── db/
│       └── monitoring/
│
├── scripts/
│   ├── deploy.sh
│   ├── destroy.sh
│   └── report.ps1
│
├── healthcheck.sh
├── logs/
└── README.md

⚙️ Step-by-Step Implementation Progress
✅ Step 1: Environment Setup

Installed all base DevOps tools on RHEL 9:

sudo dnf install -y qemu-kvm libvirt libvirt-daemon libvirt-daemon-system virt-install
sudo systemctl enable --now libvirtd
sudo dnf install -y ansible wget unzip git
sudo dnf install -y terraform


Verified:

Terraform v1.9.8 installed

Ansible operational

Libvirt active

✅ Step 2: Terraform Phase (Podman “Local Datacenter”)

Due to lack of hardware virtualization support (nested VMware environment), the project pivoted from Libvirt to Podman (Docker) as the Terraform backend.

Terraform files used:

provider.tf — defines Docker provider

main.tf — creates network and containers

output.tf — displays container details

.gitignore — excludes state files and sensitive data

Execution:

cd /root/local-datacenter-automation/terraform
terraform init
terraform validate
terraform plan
terraform apply -auto-approve

✅ Step 3: Verification

List containers:

docker ps


Output:

CONTAINER ID  IMAGE                            COMMAND               CREATED         STATUS         PORTS                 NAMES
a96c24563011  docker.io/library/nginx:latest   nginx -g daemon o...  Up 29 seconds   0.0.0.0:8080->80/tcp  web-server
bdb2b910817a  docker.io/library/mysql:8        mysqld                Up 12 seconds   3306/tcp, 33060/tcp   db-server
c33c3b7d5596  docker.io/library/alpine:latest  sh -c while true;...  Up 27 seconds                        monitor-node


Web verification:

curl http://localhost:8080


Returned the standard Nginx welcome page ✅

🧪 Health Check Script

The healthcheck.sh script validates environment readiness:

Verifies dependencies (Terraform, Ansible, Podman)

Installs missing packages

Checks service status (libvirtd, podman)

Logs results to /logs/healthcheck_<date>.log

Example:

✅ Terraform v1.9.8 installed
✅ Ansible [core 2.14.18] detected
✅ Podman API socket active

📊 Current Status
Component	Status	Notes
Terraform	✅ Installed	v1.9.8, operational
Ansible	✅ Installed	Verified locally
Libvirt / QEMU-KVM	⚠️ Inactive	Pivoted to Podman due to virtualization limits
Podman (Docker)	✅ Active	Provides lightweight “VM-like” container layer
GitHub Repo	✅ Synced	dxdiag9908/local-datacenter-automation
🧰 Issues & Troubleshooting
Issue	Root Cause	Resolution
/dev/kvm not found	Nested VMware virtualization	Switched to Podman
Merge conflict in .gitignore	Divergent Git histories	Resolved via manual merge
Terraform provider version mismatch	Cached state files	Cleaned .terraform/ and reinitialized
📈 Results

✅ Fully working Terraform local automation using Podman backend
✅ 3-container datacenter simulation: Nginx, MySQL, Alpine
✅ Verified service availability via curl http://localhost:8080
✅ Project successfully pushed to GitHub

🚀 Next Steps

Integrate Ansible playbooks for service configuration

Implement deploy.sh and destroy.sh orchestration scripts

Add PowerShell cross-platform report generator

Expand monitoring stack (Prometheus + Grafana containers)

Document network topology diagram

✍️ Author Notes

This project demonstrates how local automation environments can evolve under constraints.
When virtualization wasn’t possible, the system successfully pivoted to containers — achieving the same logical outcome with Terraform-driven automation.

“Automation that adapts is automation that lasts.”

🧩 Troubleshooting Summary

Problem:
Terraform (Libvirt) failed with /dev/kvm: No such file or directory

Root Cause:
egrep -c '(vmx|svm)' /proc/cpuinfo returned 0, confirming no hardware virtualization (running under VMware).

Solution:
Pivoted to Podman (Docker provider), enabling container-based infrastructure automation.

Commands Used:

systemd-detect-virt
sudo systemctl enable --now podman.socket
sudo ln -s /run/podman/podman.sock /var/run/docker.sock
docker ps
terraform init
terraform apply -auto-approve
curl http://localhost:8080


Outcome:
✅ Terraform successfully deployed 3 containerized services locally.
✅ Datacenter simulation achieved without KVM support.
✅ All code committed and pushed to GitHub.
