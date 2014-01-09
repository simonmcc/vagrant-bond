#!/bin/bash
#
# TODO

echo bonding >> /etc/modules
rmmod bonding
modprobe bonding

IFENSLAVE=`dpkg -l ifenslave | grep "^ii  ifenslave"`
if [ -z "${IFENSLAVE}" ]
then
    apt-get update
    apt-get install -y ifenslave
fi

echo
echo Packages installed, proceeding with configuration..
echo

echo interfaces going down
ifconfig eth0 down ; ifconfig bond0 down
pkill -9 dhclient3

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
  bond-slaves none
EOF

ps -ef | grep dhcp
ifconfig

echo
echo flushing the network interfaces
echo
echo interfaces coming up
ifconfig eth0 up ; ifconfig bond0 up
ps -ef | grep dhcp
ifconfig
echo requesting address via DHCP
nohup dhclient3 -e IF_METRIC=100 -pf /var/run/dhclient.bond0.pid -lf /var/lib/dhcp3/dhclient.bond0.leases bond0 &
ps -ef | grep dhcp
ifconfig
echo
echo current bond status
ifenslave bond0
echo
cat /proc/net/bonding/bond0

echo
echo enslaving eth0 to bond0
ifenslave bond0 eth0

echo
echo
cat /proc/net/bonding/bond0

