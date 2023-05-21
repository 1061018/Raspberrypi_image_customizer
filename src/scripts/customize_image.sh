#!/usr/bin/bash

set -e

echo "We are running the customization script!"

IMAGE_NAME=$1

# List the image partitions
fdisk -l $IMAGE_NAME

# Calculate mount offsets and assign to variables:
BOOT_OFFSET=$(fdisk -l $IMAGE_NAME | grep img1 | awk '{print $2 * 512}')

# Calculate mount size limits and assign to variables:
BOOT_SIZE=$(fdisk -l $IMAGE_NAME | grep img1 | awk '{print $4 * 512}')

# Create mount point directories:
sudo mkdir -p /mnt/rpi/img1

# Mount both partitions using the following commands:
sudo mount -o offset=$BOOT_OFFSET,sizelimit=$BOOT_SIZE $IMAGE_NAME /mnt/rpi/img1

ls -l /mnt/rpi/img1/cmdline.txt
echo "Imagem montada e pronta para ser manipulada"

# add the instruction to cmdline.txt in the boot partition to  run the firstrun.sh file
printf '%s%s' "$(head -n 1 /mnt/rpi/img1/cmdline.txt)" " systemd.run=/boot/firstrun.sh systemd.run_success_action=reboot systemd.unit=kernel-command-line.target" > /mnt/rpi/img1/cmdline.txt

cat /mnt/rpi/img1/cmdline.txt

# copy the firstrun.sh to boot partition
cp ./firstrun.sh /mnt/rpi/img1/

# always syncronize your actions before saving or umount
sync
ls -l /mnt/rpi/img1
umount /mnt/rpi/img1