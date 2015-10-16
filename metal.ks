#platform=x86, AMD64, or Intel EM64T                                                                                                                         
#version=DEVEL                                                                                                                                               
# Install OS instead of upgrade                                                                                                                              
install                                                                                                                                                      
# Firewall configuration                                                                                                                                     
firewall --enabled --ssh --service=ssh
repo --name="CentOS7"  --baseurl=http://mirrors.kernel.org/centos/7/os/x86_64/ --cost=1000
repo --name="Updates7" --baseurl=http://mirrors.kernel.org/centos/7/updates/x86_64/ 

# Keyboard layouts
keyboard 'us'# Reboot after installation

#reboot after install
reboot

# Root password
rootpw password

# System timezone
#timezone America/New_York --isUtc
timezone Africa/Harare --isUtc

# System language
lang en_US

# System services
services --disabled="avahi-daemon,iscsi,iscsid,firstboot,kdump" --enabled="network,sshd,rsyslog,tuned"

# Use network installation
url --url="http://mirrors.kernel.org/centos/7/os/x86_64/"

# Network information
network --onboot yes --bootproto=static --device=eno2 --gateway=10.200.1.1 --ip=10.200.1.12 --nameserver=4.2.2.2 --netmask=255.255.255.0 --hostname installing.marafa.vm

# System authorization information
auth  --useshadow  --passalgo=sha512
# Use text mode install

#mode
#text
cmdline

firstboot --disable

# SELinux configuration
#selinux --disabled
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
screen 
vim-enhanced 
yum-presto 
deltarpm
wget 
epel-release
ntp

%post --log=/root/post-install.log

#-#!/bin/bash
#-chroot /mnt/sysimage

echo INFO: Enabling ntp
chkconfig ntpdate on
chkconfig ntpd on

# Reboot after installation
echo INFO: Rebooting
reboot

%end
