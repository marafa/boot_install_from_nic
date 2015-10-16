#platform=x86, AMD64, or Intel EM64T                                                                                                                         
#version=DEVEL                                                                                                                                               
# Install OS instead of upgrade                                                                                                                              
install                                                                                                                                                      
# Firewall configuration                                                                                                                                     
firewall --enabled --ssh --service=ssh
#repo --name="CentOS6"  --baseurl=http://mirrors.kernel.org/centos/6/os/x86_64/ --cost=1000
repo --name="Local6"  --baseurl=http://192.168.0.31/centos6/
#repo --name="Updates6" --baseurl=http://mirrors.kernel.org/centos/6/updates/x86_64/ 

# Keyboard layouts
keyboard 'us'# Reboot after installation

#reboot after install
reboot

# Root password
rootpw password

# System timezone
timezone America/New_York

# System language
lang en_US

# System services
services --disabled="avahi-daemon,iscsi,iscsid,firstboot,kdump" --enabled="network,sshd,rsyslog,tuned"

# Use network installation
#url --url="http://mirrors.kernel.org/centos/6/os/x86_64/"
url --url="http://192.168.0.31/centos6/"

# Network information
network --onboot yes --bootproto=static --device=eth0 --gateway=192.168.0.1 --ip=192.168.0.250 --nameserver=4.2.2.2 --netmask=255.255.255.0 --hostname installing.marafa.vm

# System authorization information
auth  --useshadow  --passalgo=sha512
# Use text mode install

#mode
#text
cmdline

firstboot --disable

# SELinux configuration
selinux --disabled
# Do not configure the X Window System
skipx

# System bootloader configuration
bootloader --location=mbr --driveorder="sda" --append="rhgb crashkernel=auto quiet edd=off" 

# Partition clearing information
clearpart --all --initlabel
#autopart
part /boot --fstype=ext4 --size=500
part pv.2 --grow --size=1
volgroup vg_root --pesize=4096 pv.2
logvol / --fstype=ext4 --name=lv_root --vgname=vg_root --grow --size=1024 --maxsize=51200
logvol swap --name=lv_swap --vgname=vg_root --grow --size=1968 --maxsize=3936

%packages
@core

%post --log=/root/post-install.log

#-#!/bin/bash
#-chroot /mnt/sysimage

echo INFO: Installing custom packages 
yum -y install screen vim-enhanced git screen iotop yum-presto wget virt-what http://rdo.fedorapeople.org/openstack/rdo-release.rpm ftp://ftp.muug.mb.ca/mirror/fedora/epel/6/i386/epel-release-6-8.noarch.rpm

echo INFO: Updating 
yum -y update

echo INFO: Installing openstack-packstack 
yum -y install openstack-packstack multitail alpine byobu htop vnstat

echo INFO: Enabling ntp
chkconfig ntpdate on
chkconfig ntpd on

if ! [ -f /usr/bin/git ]
then
        echo INFO: Installing git 
        yum -y install git
fi

### openstack-os-tools.sh requires user intervention
#mkdir ~/bin
#cd ~/bin
#echo INFO: Running GIT clone
#/usr/bin/git clone https://github.com/marafa/openstack.git
#cd ~/bin/openstack

#echo INFO: Running openstack-os-tools.sh 
#./openstack-os-tools.sh
#sh /tmp/bin/openstack/./openstack-os-tools.sh
#cd

echo " INFO: Updating hosts file"
echo -e "192.168.0.5\tnotebook.marafa.vm\tnotebook" >> /etc/hosts

echo INFO: Rebooting
reboot

%end
