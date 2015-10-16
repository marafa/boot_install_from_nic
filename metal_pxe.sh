#!/bin/sh

#kickstart host
ks_host=192.168.0.30
#directory on kickstart host with the images for pxeboot
dir=centos6/images/pxeboot
#the kickstart file to use if no parameters found
[ $# -eq 0 ] && ks_file=metal.ks
if ! [ -f $1 ] 
then
  echo "ERROR: Kicktart file $1 not found"
  exit 1
fi

error_exit(){
echo "FAIL: $ks_host is not serving valid files from $dir"
exit 69
}

get_files(){
#get files
echo " INFO: Downloading boot files"
wget http://$ks_host/$dir/initrd.img -O /boot/pxe.initrd.img
[ $? -eq 0 ]|| error_exit
wget http://$ks_host/$dir/vmlinuz -O /boot/pxe.vmlinuz
[ $? -eq 0 ]|| error_exit
}

grub_config(){
echo "INFO: GRUB version 1 found. Configuring"

#stanza
cat >> /boot/grub/grub.conf << EOF
title PXE Install
        root (hd0,0)
        kernel /pxe.vmlinuz ip=192.168.0.250 netmask=255.255.255.0 gateway=192.168.0.1 lang=en keymap=us ks=http://$ks_host/metal.ks
        initrd /pxe.initrd.img
EOF

#how many entries in grub?
num=`cat /boot/grub/grub.conf |grep -i title| wc -l`

#this entry is $num -1
num=`expr $num - 1`

sed -i 's/default=.*/default='$num'/g' /boot/grub/grub.conf

echo " INFO: Setting next boot only to entry: $num"
echo "savedefault --default=$num --once" | grub --batch
}

grub_config2(){
echo "INFO: GRUB version 2 found. Configuring"
echo GRUB2 commands go here
}

get_files
rpm -q grub2 > /dev/null && grub2_config
rpm -q grub > /dev/null && grub_config
