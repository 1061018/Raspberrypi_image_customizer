#!/bin/bash

set +e

#
# em cima vai sempre
########

#Set Hostname
#vars: new_hostname
#      set_hostname

CURRENT_HOSTNAME=`cat /etc/hostname | tr -d " \t\n\r"`
if [ -f /usr/lib/raspberrypi-sys-mods/imager_custom ]; then
   /usr/lib/raspberrypi-sys-mods/imager_custom set_hostname hc
else
   echo hc >/etc/hostname
   sed -i "s/127.0.1.1.*$CURRENT_HOSTNAME/127.0.1.1\thc/g" /etc/hosts
fi


#Set SSH
#vars: enable_ssh
#      set_user
#      ssh_public_key

FIRSTUSER=`getent passwd 1000 | cut -d: -f1`
FIRSTUSERHOME=`getent passwd 1000 | cut -d: -f6`


if [ -f /usr/lib/raspberrypi-sys-mods/imager_custom ]; then
   /usr/lib/raspberrypi-sys-mods/imager_custom enable_ssh -k 'ssh_test_key00000111112222'
else
   install -o "$FIRSTUSER" -m 700 -d "$FIRSTUSERHOME/.ssh"
   install -o "$FIRSTUSER" -m 600 <(printf "ssh_test_key00000111112222") "$FIRSTUSERHOME/.ssh/authorized_keys"
   echo 'PasswordAuthentication no' >>/etc/ssh/sshd_config
   systemctl enable ssh
fi

#vars: enable_ssh
#      password_authentication

if [ -f /usr/lib/raspberrypi-sys-mods/imager_custom ]; then
   /usr/lib/raspberrypi-sys-mods/imager_custom enable_ssh
else
   systemctl enable ssh
fi


#user
#vars: user_name
#      user_password
#      

if [ -f /usr/lib/userconf-pi/userconf ]; then
   /usr/lib/userconf-pi/userconf 'hc' 'passdo_hc'
else
   echo "$FIRSTUSER:"'passdo_hc' | chpasswd -e
   if [ "$FIRSTUSER" != "hc" ]; then
      usermod -l "hc" "$FIRSTUSER"
      usermod -m -d "/home/hc" "hc"
      groupmod -n "hc" "$FIRSTUSER"
      if grep -q "^autologin-user=" /etc/lightdm/lightdm.conf ; then
         sed /etc/lightdm/lightdm.conf -i -e "s/^autologin-user=.*/autologin-user=hc/"
      fi
      if [ -f /etc/systemd/system/getty@tty1.service.d/autologin.conf ]; then
         sed /etc/systemd/system/getty@tty1.service.d/autologin.conf -i -e "s/$FIRSTUSER/hc/"
      fi
      if [ -f /etc/sudoers.d/010_pi-nopasswd ]; then
         sed -i "s/^$FIRSTUSER /hc /" /etc/sudoers.d/010_pi-nopasswd
      fi
   fi
fi


#fim user

# wifi
#vars: enable_wifi
#      wifi_ssid
#      wifi_pass
#      wifi_country
#      hidden_ssid

if [ -f /usr/lib/raspberrypi-sys-mods/imager_custom ]; then
   /usr/lib/raspberrypi-sys-mods/imager_custom set_wlan -h 'meo-cenas' 'passdaMeo' 'PT'
else
cat >/etc/wpa_supplicant/wpa_supplicant.conf <<'WPAEOF'
country=PT
ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev
ap_scan=1

update_config=1
network={
   scan_ssid=1
	ssid="meo-cenas"
	psk=passdaMeo
}

WPAEOF
   chmod 600 /etc/wpa_supplicant/wpa_supplicant.conf
   rfkill unblock wifi
   for filename in /var/lib/systemd/rfkill/*:wlan ; do
       echo 0 > $filename
   done
fi


#timezone e teclado
# set_local
# keyboard
# timezone

if [ -f /usr/lib/raspberrypi-sys-mods/imager_custom ]; then
   /usr/lib/raspberrypi-sys-mods/imager_custom set_keymap 'pt'
   /usr/lib/raspberrypi-sys-mods/imager_custom set_timezone 'europ/lisbon'
else
   rm -f /etc/localtime
   echo "europ/lisbon" >/etc/timezone
   dpkg-reconfigure -f noninteractive tzdata
cat >/etc/default/keyboard <<'KBEOF'
XKBMODEL="pc105"
XKBLAYOUT="pt"
XKBVARIANT=""
XKBOPTIONS=""

KBEOF
   dpkg-reconfigure -f noninteractive keyboard-configuration
fi

####

######
#em baixo vai sempre
#####

rm -f /boot/firstrun.sh
sed -i 's| systemd.run.*||g' /boot/cmdline.txt
exit 0