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

This project automates the creation and configuration of a small, realistic “local data center” on RHEL 9.
It demonstrates an end-to-end automation workflow using Terraform, Ansible, and Bash, all running locally with Podman as the container backend.

🎯 Goal

To simulate a self-contained infrastructure that mirrors a data center’s provisioning and configuration pipeline — entirely offline and cloud-independent.

🧱 Tech Stack
Tool	Purpose
Terraform	Provision and orchestrate infrastructure
Ansible	Configure and manage services post-deployment
Bash	Automate health checks, validation, and orchestration
PowerShell (optional)	Cross-platform reporting and status checks
Podman	Lightweight container runtime for local “VM-like” simulation
Libvirt / QEMU-KVM (initial attempt)	Virtualization backend — later replaced due to lack of hardware support
🏗️ Target Environment
Node	Role	OS / Image	Function
web-server	Web Server	nginx:latest	Serves static content
db-server	Database Server	mysql:8	Backend data services
monitor-node	Monitoring Node	alpine:latest	Simulated metrics collection
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

Installed and verified required tooling on RHEL 9:

sudo dnf install -y qemu-kvm libvirt libvirt-daemon libvirt-daemon-system virt-install
sudo systemctl enable --now libvirtd
sudo dnf install -y ansible wget unzip git terraform


Verification:

✅ Terraform v1.9.8 operational

✅ Ansible [core 2.14.18] functional

✅ Podman socket active

⚠️ Libvirt skipped due to missing /dev/kvm

✅ Step 2: Terraform Phase (Pivot to Podman)

Since nested VMware prevented hardware virtualization, Terraform was reconfigured to use Podman (Docker provider) for containerized simulation.

Key files:

provider.tf → defines Docker provider via Podman socket

main.tf → creates containers and network

output.tf → outputs container details

.gitignore → excludes binaries, logs, and state files

Execution:

cd terraform/
terraform init
terraform validate
terraform plan
terraform apply -auto-approve


Result:

3 containers deployed (nginx, mysql, alpine)

Verified via curl http://localhost:8080 → Nginx welcome page OK

✅ Step 3: Ansible Integration (New)

Ansible is now incorporated to configure the containers post-deployment.

Example:

cd ansible/
ansible-playbook -i inventory.ini playbooks/webserver.yml


Inventory Sample:

[web]
localhost ansible_connection=local

[db]
localhost ansible_connection=local

[monitor]
localhost ansible_connection=local


This allows Ansible to:

Deploy Nginx configuration templates

Initialize MySQL with default schema

Simulate a monitoring node setup

✅ Step 4: Git Cleanup & Version Control

During today’s updates:

Merge conflict detected in .gitignore

Resolved manually and rebased successfully

Clean .gitignore now excludes large binaries, ISOs, logs, and Terraform state

Final .gitignore:

# Ignore ISO and VM image files
*.iso
*.qcow2
*.img

# Logs
logs/*
*.log

# Terraform state files
.terraform/
terraform.tfstate*
terraform.tfstate.backup

# Ansible temporary files
*.retry


Verification:

git status
# nothing to commit, working tree clean

🧪 Health Check Script

healthcheck.sh verifies:

Terraform, Ansible, Podman presence

Service status (libvirtd, podman.socket)

Logs results to /logs/healthcheck_<timestamp>.log

Example output:

✅ Terraform v1.9.8 installed
✅ Ansible [core 2.14.18] detected
✅ Podman API socket active

📊 Current Status
Component	Status	Notes
Terraform	✅	Functional, Podman backend
Ansible	✅	Integrated for config mgmt
Libvirt / KVM	⚠️	Disabled — hardware limitation
Podman	✅	Container-based datacenter simulation
GitHub Repo	✅	Synced: dxdiag9908/local-datacenter-automation
🧰 Issues & Troubleshooting
Issue	Root Cause	Resolution
/dev/kvm missing	Nested VMware lacks hardware virtualization	Pivoted to Podman
.gitignore merge conflict	Divergent repo histories	Manually merged and rebased
Terraform state errors	Cached .terraform/ artifacts	Cleaned and reinitialized
Ansible permission denied	SELinux + local connections	Used --connection=local and verified permissions
📈 Results

✅ Fully operational Terraform + Ansible local automation
✅ 3-container datacenter successfully deployed and configured
✅ Clean Git state, repository pushed to GitHub
✅ All infrastructure verified via curl and Ansible playbooks

🚀 Next Steps

Expand Ansible playbooks for service hardening

Implement orchestration scripts (deploy.sh, destroy.sh)

Add PowerShell-based cross-platform reports

Add monitoring stack (Prometheus + Grafana)

Create visual network diagram for documentation

✍️ Author Notes

This project shows adaptive automation in action:
When virtualization wasn’t possible, the stack pivoted seamlessly to containers.
With Terraform and Ansible working in tandem, a complete local datacenter simulation is achieved — infrastructure + configuration, fully automated.

“Automation that adapts is automation that lasts.”

🧩 Troubleshooting Summary

Problem:
Terraform (Libvirt) failed: /dev/kvm: No such file or directory

Root Cause:
No hardware virtualization support under VMware (egrep -c '(vmx|svm)' /proc/cpuinfo → 0)

Solution:
Pivoted to Podman backend. Linked Podman socket to Docker-compatible API:

sudo systemctl enable --now podman.socket
sudo ln -s /run/podman/podman.sock /var/run/docker.sock
terraform apply -auto-approve
curl http://localhost:8080


Outcome:
✅ Terraform successfully deployed all services
✅ Ansible verified configuration
✅ Environment teardown verified with:

terraform destroy -auto-approve
podman ps -a
podman network ls
