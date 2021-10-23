# Apply updates and cleanup yum cache
#
echo "Update packages"
yum update -y
yum clean packages
yum clean metadata
yum clean all

# Disable swap - generally recommended for K8s, but otherwise enable it for other workloads
#
echo "Disable sawp"
swapoff -a
sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab

# Reset the machine-id value. This has known to cause issues with DHCP
#
echo "Reset machine-id"
echo -n > /etc/machine-id

# Reset any existing cloud-init state
#
echo "Resetting Cloud-Init"
ls -d /etc/cloud/cloud.cfg.d/* | grep .cfg | grep -v 05_logging | xargs -I % mv % %.disabled
rm -f /etc/cloud/cloud-init.disabled
cloud-init clean -s -l

# Add cloud-init-vmware-guestinfo
#
echo "Install cloud-init-vmware-guestinfo"
curl -sSL https://raw.githubusercontent.com/vmware/cloud-init-vmware-guestinfo/master/install.sh | sh -
