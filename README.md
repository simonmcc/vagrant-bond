# vagrant-bond

A quick example of converting eth0 to bond0 inside a Vagrant managed vbox

Currently converts eth0 to bond0 with active-backup, and re-requests an IP address over DHCP, so that "vagrant ssh" continues to work as expected.

Some of the steps are done outside of /etc/network/interfaces as things just stopped working.

Useful for testing config management stuff that assumes bond0 etc
