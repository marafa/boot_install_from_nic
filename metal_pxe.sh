#!/bin/sh

#variables
#kickstart host
ks_host=mirror.centos.org
#directory on kickstart host with the images for pxeboot
hw_type=`uname -m`
dir=centos/7/os/$hw_type/images/pxeboot
#the kickstart file to use if no parameters found
[ $# -eq 0 ] && ks_file=metal.ks
network=10.200.1
ip=$network.12
gw=$network.1

error_exit(){
echo "FAIL: $ks_host is not serving valid files from $dir"
exit 69
}

get_files(){
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
        kernel /pxe.vmlinuz ip=$ip netmask=255.255.255.0 gateway=$gw lang=en keymap=us ks=http://$ks_host/metal.ks
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

grub2_config(){
echo "INFO: GRUB version 2 found. Configuring"

cat >> /etc/grub.d/40_custom << EOF
#!/bin/sh
exec tail -n +3 $0
# This file provides an easy way to add custom menu entries.  Simply type the
# menu entries you want to add after this comment.  Be careful not to change
# the 'exec tail' line above.
#
menuentry "Install from network" {
    set root=(hd0,0)
    linux /pxe.vmlinuz ip=$ip netmask=255.255.255.0 gateway=$gw lang=en keymap=us ks=http://$ks_host/metal.ks
    initrd /pxe.initrd.img
#not sure if next line is required
#    savedefault
}
EOF

#modify /etc/default/grub
#not sure if next line is required
grep GRUB_SAVEDEFAULT /etc/default/grub > /dev/null
[ $? -eq 0 ] || echo "GRUB_SAVEDEFAULT=true" >> /etc/default/grub
#most important line
sed -i 's/GRUB_DEFAULT=.*/GRUB_DEFAULT=saved/g' /etc/default/grub

#how many entries in grub?
num=`grub2-editenv list |wc -l`

#tell grub to reboot to this stanza next time only
#grub2-reboot $num
grub2-reboot  "Install from network"
#last step; update grub
grub2-mkconfig -o /boot/grub/grub.cfg
}

get_files
rpm -q grub2 > /dev/null && grub2_config
rpm -q grub > /dev/null && grub_config

##list menu entries
#grep "submenu\|^menuentry" /boot/grub2/grub.cfg  | cut -d "'" -f2
