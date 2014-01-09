#!/bin/bash
#
# TODO

rmmod bonding
echo bonding >> /etc/modules
cat << EOF > /etc/modprobe.d/bond0
alias netdev-bond0 bonding
options bonding mode=1
EOF

IFENSLAVE=`dpkg -l ifenslave | grep "^ii  ifenslave"`
if [ -z "${IFENSLAVE}" ]
then
    apt-get update
    apt-get install -y ifenslave
fi

echo
echo Packages installed..
echo Interfaces going down..this may be the last thing you will see!
ifconfig eth0 down ; ifconfig bond0 down
pkill -9 dhclient3

echo Updating /etc/network/interfaces..
cat << EOF > /etc/network/interfaces
auto lo
iface lo inet loopback

# Bonding eth0
auto eth0
iface eth0 inet manual
  bond-master bond0
  bond-primary eth0

# Bonding eth1
auto eth1
iface eth1 inet manual
  bond-master bond0

# Mgmnt Interface
#     Internal IP used by Nova backends and OPS
auto bond0
iface bond0 inet manual
  bond-mode active-backup
  bond-miimon 100
  bond-slaves eth0 eth1
EOF


echo
echo Bringing up network interfaces
echo
ifconfig eth0 up ; ifconfig eth1 up ; ifconfig bond0 up
echo requesting address via DHCP
nohup dhclient3 -e IF_METRIC=100 -pf /var/run/dhclient.bond0.pid -lf /var/lib/dhcp3/dhclient.bond0.leases bond0 &

echo
echo "Current bond status (/proc/net/bonding/bond0)"
cat /proc/net/bonding/bond0

echo
echo enslaving eth0 to bond0
ifenslave bond0 eth0 eth1

echo "Current bond status (/proc/net/bonding/bond0)"
cat /proc/net/bonding/bond0
