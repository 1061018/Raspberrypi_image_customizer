#!/usr/bin/bash

echo "We are running the customization script!"


# List the image partitions
fdisk -l 2023-02-21-raspios-buster-armhf-lite.img

# Calculate mount offsets and assign to variables:
BOOT_OFFSET=$(fdisk -l 2023-02-21-raspios-buster-armhf-lite.img | grep img1 | awk '{print $2 * 512}')

# Calculate mount size limits and assign to variables:
BOOT_SIZE=$(fdisk -l 2023-02-21-raspios-buster-armhf-lite.img | grep img1 | awk '{print $4 * 512}')

# Create mount point directories:
sudo mkdir -p /mnt/rpi/img1

# Mount both partitions using the following commands:
sudo mount -o offset=$BOOT_OFFSET,sizelimit=$BOOT_SIZE 2023-02-21-raspios-buster-armhf-lite.img /mnt/rpi/img1

ls -l /mnt/rpi/img1/cmdline.txt
echo "Imagem montada e pronta para ser manipulada"
