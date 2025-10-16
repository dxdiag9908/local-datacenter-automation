#!/bin/bash
# ==========================================================
# 🩺 Local Data Center Health Check & Setup Script
# ==========================================================
set -e

echo "=========================================================="
echo "=== 🩺 Local Data Center Health Check & Setup Script ==="
echo "=========================================================="

# Create logs directory if missing
mkdir -p logs

# Function to check and install a package
check_install() {
  pkg=$1
  if rpm -q $pkg &>/dev/null; then    echo "✅ $pkg already installed."
  else
    echo "📦 Installing $pkg ..."
    sudo dnf install -y $pkg >/dev/null 2>&1 && echo "✅ Installed $pkg."
  fi
}

echo "=== 🔍 Checking system dependencies ==="
for pkg in qemu-kvm libvirt libvirt-daemon libvirt-daemon-config-network libvirt-daemon-driver-qemu virt-install; do
  check_install $pkg
done


# ----------------------------------------------------------
# Terraform Check
# ----------------------------------------------------------
echo "=== 🧱 Checking Terraform ==="
if ! command -v terraform &>/dev/null; then
  echo "📦 Terraform not found, installing..."
  wget -q https://releases.hashicorp.com/terraform/1.9.8/terraform_1.9.8_linux_amd64.zip -O /tmp/terraform.zip
  unzip -q /tmp/terraform.zip -d /usr/local/bin
  rm -f /tmp/terraform.zip
  echo "✅ Terraform installed: $(terraform -v | head -n1)"
else
  echo "✅ Terraform already installed: $(terraform -v | head -n1)"
fi

# ----------------------------------------------------------
# Ansible Check
# ----------------------------------------------------------
echo "=== ⚙️ Checking Ansible ==="
if ! command -v ansible &>/dev/null; then
  echo "📦 Installing Ansible..."
  sudo dnf install -y ansible >/dev/null 2>&1 && echo "✅ Ansible installed."
else
  echo "✅ Ansible already installed: $(ansible --version | head -n1)"
fi

# ----------------------------------------------------------
# Libvirt service check
# ----------------------------------------------------------
echo "=== 🧩 Checking libvirt service ==="
if systemctl is-active --quiet libvirtd; then
  echo "✅ libvirtd service is active."
else
  echo "⚠️ libvirtd not active, starting..."
  sudo systemctl enable --now libvirtd && echo "✅ libvirtd started."
fi

# ----------------------------------------------------------
# Group Membership Check
# ----------------------------------------------------------
echo "=== 👤 Checking user permissions ==="
USER_NAME=$(whoami)
for grp in libvirt kvm; do
  if groups $USER_NAME | grep -q "\b$grp\b"; then
    echo "✅ User '$USER_NAME' is in group '$grp'."
  else
    echo "⚠️ Adding '$USER_NAME' to group '$grp'..."
    sudo usermod -aG $grp $USER_NAME
    echo "✅ Added '$USER_NAME' to '$grp'. You must log out/in for changes to take effect."
  fi
done

# ----------------------------------------------------------
# Virsh connectivity check
# ----------------------------------------------------------
echo "=== 🧠 Verifying virsh connection ==="
if virsh list --all >/dev/null 2>&1; then
  echo "✅ virsh is communicating with libvirt successfully."
else
  echo "❌ virsh cannot connect. Check libvirt configuration or URI settings."
fi

# ----------------------------------------------------------
# Summary
# ----------------------------------------------------------
echo "=========================================================="
echo "✅ Health Check Complete!"
echo "📋 Summary:"
echo "  • Terraform: $(terraform -v | head -n1 2>/dev/null || echo 'Not installed')"
echo "  • Ansible: $(ansible --version | head -n1 2>/dev/null || echo 'Not installed')"
echo "  • libvirtd: $(systemctl is-active libvirtd)"
echo "  • User groups: $(groups $USER_NAME)"
echo "=========================================================="

