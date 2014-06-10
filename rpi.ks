# Build the image with
# image-creator -f rpi-f20-1 --mbr rpi.ks
# Use the image-creator from https://github.com/fedora-rpi/livecd-tools package

lang en_US.UTF-8
keyboard us
timezone US/Eastern
auth --useshadow --enablemd5
# TODO: Get rid of the mmap_zero denials
selinux --permissive
firewall --enabled --service=mdns
xconfig --startxonboot

part /boot --size=128 --fstype vfat --label BOOT
part / --size=768 --grow --fstype ext4

services --enabled=NetworkManager --disabled=network

repo --name=pidora --mirrorlist=http://pidora.proximity.on.ca/mirrorlist/mirrorlist.cgi?repo=pidora-$releasever&arch=$basearch
repo --name=pidora-updates --mirrorlist=http://pidora.proximity.on.ca/mirrorlist/mirrorlist.cgi?repo=pidora-updates-$releasever&arch=$basearch
repo --name=fedora-rpi --baseurl=http://fedorapeople.org/~lkundrak/fedora-rpi/$releasever/
# Enable this for Rawhide kernel rebuild
#repo --name=fedora-rpi-devel --baseurl=http://fedorapeople.org/~lkundrak/fedora-rpi/devel/

%packages
@core
-pidora-release
generic-release
kernel
uboot-tools
uboot-images-armv6
dracut-modules-growroot
raspberrypi-vc-firmware
# Not strictly needed, but useful: Out boot is a msdos filesystem and this
# is useful for automated systemd-triggered check
dosfstools
# The device has no RTC
chrony
%end

%post
# Add drivers to initrd
V=$(ls /lib/modules)
cat >/etc/dracut.conf.d/bcm2835.conf <<EOF
add_drivers+="sdhci_bcm2835 sdhci_pltfm"
EOF
dracut -v -f /boot/initramfs-$V.img $V

# Install bootloader
cp /usr/share/uboot/rpi_b/u-boot.bin /boot/kernel.img

# Remove root password
passwd -d root
%end
