# Apply updates and cleanup tdnf cache
#
echo "Update packages"
tdnf upgrade -y
tdnf clean all

# Disable swap - generally recommended for K8s, but otherwise enable it for other workloads
#
echo "Disable sawp"
swapoff -a
sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab

# Reset the machine-id value. This has known to cause issues with DHCP
#
echo "Reset machine-id"
echo -n > /etc/machine-id
rm /var/lib/dbus/machine-id
ln -s /etc/machine-id /var/lib/dbus/machine-id

# Reset any existing cloud-init state
#
echo "Resetting Cloud-Init"
rm -f /var/log/cloud-init*
cloud-init clean -s -l
