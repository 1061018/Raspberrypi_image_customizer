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
   /usr/lib/raspberrypi-sys-mods/imager_custom set_hostname pi-hc
else
   echo pi-hc >/etc/hostname
   sed -i "s/127.0.1.1.*$CURRENT_HOSTNAME/127.0.1.1\tpi-hc/g" /etc/hosts
fi


#Set SSH
#vars: enable_ssh
#      set_user
#      ssh_public_key

FIRSTUSER=`getent passwd 1000 | cut -d: -f1`
FIRSTUSERHOME=`getent passwd 1000 | cut -d: -f6`


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
   /usr/lib/userconf-pi/userconf 'hc' '$5$owB.t1DRKJ$TEYZ3pp1FnhiEpS1IjHFo2FXzw4ogLitO2trB3VKtiC'
else
   echo "$FIRSTUSER:"'$5$owB.t1DRKJ$TEYZ3pp1FnhiEpS1IjHFo2FXzw4ogLitO2trB3VKtiC' | chpasswd -e
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
   /usr/lib/raspberrypi-sys-mods/imager_custom set_wlan 'MEO-829250' 'e97ed8178977e6ebccc466190dc805d59d8adec96195a3014f7d44aae8926d46' 'PT'
else
cat >/etc/wpa_supplicant/wpa_supplicant.conf <<'WPAEOF'
country=PT
ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev
ap_scan=1

update_config=1
network={

	ssid="MEO-829250"
	psk=e97ed8178977e6ebccc466190dc805d59d8adec96195a3014f7d44aae8926d46
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
   /usr/lib/raspberrypi-sys-mods/imager_custom set_timezone 'Europe/Lisbon'
else
   rm -f /etc/localtime
   echo "Europe/Lisbon" >/etc/timezone
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