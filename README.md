# 🧠 Local Data Center Automation  
### Fully Automated Infrastructure Simulation on RHEL 9  

---

## 📑 Table of Contents
- Overview  
- Goal  
- Tech Stack  
- Target Environment  
- Project Structure  
- Implementation Progress  
- Health Check Script  
- Current Status  
- Issues & Troubleshooting  
- Results  
- 🔄 Project Reset & Validation (Post-Recovery)  
- Next Steps  
- Author Notes  
- Troubleshooting Summary  

---

## 📘 Overview
This project automates the creation and configuration of a small, realistic “local data center” on **RHEL 9**.  
It demonstrates an end-to-end automation workflow using **Terraform**, **Ansible**, and **Bash**,  
all running locally with **Podman** as the container backend.

---

## 🎯 Goal
To simulate a self-contained infrastructure that mirrors a data center’s provisioning and configuration pipeline — entirely offline and cloud-independent.

---

## 🧱 Tech Stack

| Tool | Purpose |
|------|----------|
| **Terraform** | Provision and orchestrate infrastructure |
| **Ansible** | Configure and manage services post-deployment |
| **Bash** | Automate health checks, validation, and orchestration |
| **PowerShell (optional)** | Cross-platform reporting and status checks |
| **Podman** | Lightweight container runtime for local “VM-like” simulation |
| **Libvirt / QEMU-KVM (initial attempt)** | Virtualization backend — later replaced due to lack of hardware support |

---

## 🏗️ Target Environment

| Node | Role | OS / Image | Function |
|------|------|-------------|-----------|
| web-server | Web Server | nginx:latest | Serves static content |
| db-server | Database Server | mysql:8 | Backend data services |
| monitor-node | Monitoring Node | alpine:latest | Simulated metrics collection |

---

## 📂 Project Structure

local-datacenter-automation/
├── terraform/
│ ├── main.tf
│ ├── provider.tf
│ ├── output.tf
│ └── .gitignore
│
├── ansible/
│ ├── inventory.ini
│ ├── playbooks/
│ │ ├── webserver.yml
│ │ ├── database.yml
│ │ └── monitoring.yml
│ └── roles/
│ ├── web/
│ ├── db/
│ └── monitoring/
│
├── scripts/
│ ├── deploy.sh
│ ├── destroy.sh
│ └── report.ps1
│
├── healthcheck.sh
├── logs/
└── README.md


---

## ⚙️ Step-by-Step Implementation Progress

### ✅ Step 1: Environment Setup
Installed and verified required tooling on RHEL 9:
```bash
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
✅ 3 containers deployed (nginx, mysql, alpine)
✅ Verified via curl http://localhost:8080 → Nginx welcome page OK

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

During updates:

Merge conflict detected in .gitignore → resolved and rebased successfully

Clean .gitignore excludes binaries, ISOs, logs, and Terraform state
Verification:
git status

→ nothing to commit, working tree clean

🧪 Health Check Script

healthcheck.sh verifies:

Terraform, Ansible, Podman presence

Service status (libvirtd, podman.socket)

Logs results to /logs/healthcheck_*.log

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

🔄 Project Reset & Validation (Post-Recovery)

After a brief break due to illness that affected our household for two weeks, I returned to this project and performed a full environment refresh and validation.

I revalidated every layer — RHEL 9 system, Terraform, Ansible, Podman, and all configuration files — ensuring everything was operational.

As part of this process:

Verified tool versions:
terraform -v
ansible --version
podman version

✅ Terraform v1.9.8
✅ Ansible [core 2.14.18]
✅ Podman Engine v5.4.0

Ran full Terraform validation cycle:

cd ~/local-datacenter-automation/terraform
terraform init
terraform validate
terraform plan

Re-ran the healthcheck.sh script to confirm component integrity.

Discovered that my inventory.ini file had been removed or misplaced.
I recreated it manually and successfully verified Ansible connectivity:

ansible all -i inventory.ini -m ping
✅ 127.0.0.1 | SUCCESS => "pong"
⚠️ Remote nodes (192.168.122.*) unreachable — to be revisited later.

This refresh confirmed that the core environment is healthy and consistent across tools and layers.

🚀 Next Steps

Expand Ansible playbooks for service hardening

Implement orchestration scripts (deploy.sh, destroy.sh)

Add PowerShell-based cross-platform reports

Add monitoring stack (Prometheus + Grafana)

Create visual network diagram for documentation

✍️ Author Notes

This project shows adaptive automation in action: when virtualization wasn’t possible, the stack pivoted seamlessly to containers.
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

✅ Phase: VM Preparation + Role Structure + Initial Playbook Execution
1. Inventory File Completed

You created a clean and correct inventory.ini grouping hosts by role:

[web]

[db]

[monitor]

This establishes the structure Ansible uses to target machines.

✅ Phase: Ansible Directory Structure

Inside your project (local-datacenter-automation/ansible), you now have:

ansible/
 ├── inventory.ini
 ├── playbooks/
 │    ├── webserver.yml
 │    ├── database.yml
 │    └── monitoring.yml
 └── roles/
      ├── web/
      │    └── tasks/main.yml
      ├── db/
      │    └── tasks/main.yml
      └── monitor/
           └── tasks/main.yml

This is the proper Ansible role layout, and Ansible successfully detected the roles directory.

✅ Phase: VM Discovery and Debugging
✔ VMs were successfully created via script

You confirmed:

virsh list --all

Shows:

web (running)

db (running)

monitor (running)

✔ Networks checked
virsh net-list --all

Confirmed default libvirt network is active.

✔ VM interfaces seen via:
virsh domiflist web
virsh domiflist db
virsh domiflist monitor

Each VM has:

1 NIC

Connected to default network

Unique MAC addresses

⚠ Issue: No IP Addresses Detected

virsh domifaddr <vm> returned no IPs, meaning:

The OS inside the VM isn't installed yet

Therefore, DHCP never requested an address

No SSH possible → Ansible cannot connect

This is why playbooks failed with:

UNREACHABLE! No route to host / Connection timed out

Because the machines exist but do not yet have an operating system, therefore:

No network

No IP

No SSH service running

⚠ Next Critical Step (Pending)
Install AlmaLinux 9 inside each VM (web, db, monitor)

Until OS installation is done, Ansible cannot configure anything.

We planned to return to this step tomorrow.

Summary of What We Achieved
✔ Created full Ansible role structure
✔ Created playbooks for web, db, monitor
✔ Confirmed directory layout works
✔ Verified libvirt VMs exist and run
✔ Confirmed network is active
✔ Diagnosed connectivity issue correctly
✔ Determined next logical step: OS installation

You are now one small step away from full end‑to‑end automation.

What Happens Next (Tomorrow)

Boot each VM using AlmaLinux ISO

Install OS manually (first time only)

Configure SSH + network

Retrieve VM IPs

Update inventory.ini

Re-run Ansible playbooks successfully

Once OS installs are done, real automation begins.

End of README update.

🧩 Latest Work Session — VM Creation, Networking & Ansible Prep

Today’s session focused on preparing the environment for full Ansible-driven automation by shifting from container‑based simulation to real VM‑based infrastructure using Libvirt + QEMU-KVM. Even though the VMs are not yet fully configured, a foundational layer has been built.

✔️ Key Actions Completed

Verified that the default Libvirt network is active and functional.

Created three VMs (web, db, monitor) via automated script.

Ensured all VMs are running (virsh list --all → all three active).

Confirmed network interfaces:

web → vnet0

db → vnet1

monitor → vnet2

Attached to VM consoles using:

virsh console web
virsh console db
virsh console monitor

Noted that IP addresses were not yet assigned (cloud‑init not applied).

⚠️ Current Limitations

No DHCP leases → VMs report no IP address (virsh domifaddr empty).

As a result, Ansible failed SSH connections:

UNREACHABLE! No route to host (port 22)

VM OS installation still required (AlmaLinux ISO available at /var/lib/libvirt/boot/alma9-seed.iso).

📌 Next Step (Deferred)

Install AlmaLinux 9 on each VM, configure networking, and enable SSH so Ansible can connect. This will allow the existing playbooks (web, db, monitor roles) to run successfully.

📝 Summary

This session established the full virtualization layer for the upgraded local datacenter model. While the VMs are running and network‑attached, they still require OS installation and network configuration before the automation pipeline continues. The environment is now ready for the critical next phase: OS provisioning + initial SSH setup to unlock full Ansible automation.
