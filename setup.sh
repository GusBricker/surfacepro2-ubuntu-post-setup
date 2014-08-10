#!/bin/bash


DIR=$(pwd)
. include/common.sh

[ -f ${LOG_FILE} ] && rm ${LOG_FILE}

exec >  >(tee -a ${LOG_FILE})
exec 2> >(tee -a ${LOG_FILE} >&2)
#
## Surface Pro Kernel
DoEcho "Installing base kernel version"
AptInstall linux-headers-${KERNEL_VERSION}-generic
AptInstall linux-tools-${KERNEL_VERSION}-generic
AptInstall linux-cloud-tools-${KERNEL_VERSION}-generic
AptInstall linux-images-${KERNEL_VERSION}-generic
AptFixDeps

DoEcho "Installing new kernel"
dpkg -i "${DELIVERY_DIR}/kernel/linux-headers-${KERNEL_VERSION}" "${DELIVERY_DIR}/kernel/linux-tools-${KERNEL_VERSION}" "${DELIVERY_DIR}/kernel/linux-cloud-tools-${KERNEL_VERSION}" "${DELIVERY_DIR}/kernel/linux-image-${KERNEL_VERSION}"
AptFixDeps

DoEcho "Marking new kernel to be held to stop auto updates breaking the system!"
HoldPackage "linux-headers-${KERNEL_VERSION}-surfacepro"
HoldPackage "linux-tools-${KERNEL_VERSION}-surfacepro"
HoldPackage "linux-cloud-tools-${KERNEL_VERSION}-surfacepro"
HoldPackage "linux-image-${KERNEL_VERSION}-surfacepro"

#
## WiFi
DoEcho "Installing Marvel WiFi driver"
DeliverFile "wifi/usb8798_uapsta.bin" "/lib/firmware/mrvl/"

#
## Disk
DoEcho "Installing cron job for daily disk trimming"
DeliverFile "disk/trim" "/etc/cron.daily/"

#
## Hibernate
DoEcho "Setting up Ubuntu to hibernate"
DeliverFile "hibernation/com.ubuntu.enable-hibernate.pkla" "/var/lib/polkit-1/localauthority/50-local.d/"

#
## Default Brightness
DoEcho "Dropping default brightness"
DeliverFile "power/rc.local" "/etc/"

#
## Power Management
DoEcho "Installing some power management utilities"
AptInstall powertop
AptInstall pm-utils
#AptInstall laptop-mode-tools
AptInstall fancontrol

DeliverFile "power/99-savings" "/etc/pm/sleep.d/"
ln -s "/etc/pm/power.d/99-savings" "/etc/pm/sleep.d/99-savings"
#DeliverFile "power/10-laptop-mode-tools" "/etc/pm/sleep.d/"

#
## GINN
DoEcho "Installing ginn for some nice touch gestures!"
AptInstall ginn
