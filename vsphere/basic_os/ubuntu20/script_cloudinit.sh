# Apply updates and cleanup Apt cache
#
echo "Update packages"
apt-get update ; apt-get -y dist-upgrade
apt-get -y autoremove
apt-get -y clean

# Disable swap - generally recommended for K8s, but otherwise enable it for other workloads
#
echo "Disable sawp"
swapoff -a
sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab

# Reset the machine-id value. This has known to cause issues with DHCP
#
echo "Reset machine-id"
truncate -s 0 /etc/machine-id
rm /var/lib/dbus/machine-id
ln -s /etc/machine-id /var/lib/dbus/machine-id

# Reset any existing cloud-init state
#
echo "Reset Cloud-Init"
ls -d /etc/cloud/cloud.cfg.d/*.cfg | grep -v 05_logging | xargs -I % mv % %.disabled
cloud-init clean -s -l

# Add cloud-init-vmware-guestinfo
#
echo "Install cloud-init-vmware-guestinfo"
curl -sSL https://raw.githubusercontent.com/vmware/cloud-init-vmware-guestinfo/master/install.sh | sh -
sed -i "s/^ssh_pwauth.*/ssh_pwauth: 1/; s/^disable_vmware_customization.*/disable_vmware_customization: false/" /etc/cloud/cloud.cfg
sed -i "s/^datasource_list.*/datasource_list: ['VMware', 'VMwareGuestInfo', 'NoCloud', 'OVF', 'ConfigDrive', 'OpenStack', None]/" /etc/cloud/cloud.cfg.d/99-DataSourceVMwareGuestInfo.cfg

# Remove old netplan configs
#
echo "Removing existing Netplan config file"
rm /etc/netplan/*.yaml