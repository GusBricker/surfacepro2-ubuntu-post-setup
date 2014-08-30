#!/bin/bash


DIR=$(pwd)
. include/common.sh

[ -f ${LOG_FILE} ] && rm ${LOG_FILE}

exec >  >(tee -a ${LOG_FILE})
exec 2> >(tee -a ${LOG_FILE} >&2)


if [[ $EUID -ne 0 ]];
then
    DoEcho "Script must be run as root"
    exit 1
fi

#
## Custom Linux Kernel
DoEcho "Installing new kernel"
dpkg -i "${DELIVERY_DIR}/kernel/linux-headers-${KERNEL_VERSION}-${KERNEL_LOCAL_VERSION}_${KERNEL_ARCH}.deb" "${DELIVERY_DIR}/kernel/linux-image-${KERNEL_VERSION}-${KERNEL_LOCAL_VERSION}_${KERNEL_ARCH}.deb"
CheckLastResult $? "Failed installing new kernel"
AptFixDeps
CheckLastResult $? "Failed installing new kernel"

DoEcho "Marking new kernel to be held to stop auto updates breaking the system!"
HoldPackage "linux-headers-${KERNEL_VERSION}-${KERNEL_LOCAL_VERSION}"
CheckLastResult $? "Failed to hold kernel headers"
HoldPackage "linux-image-${KERNEL_VERSION}-${KERNEL_LOCAL_VERSION}"
CheckLastResult $? "Failed to hold kernel image"

#
## WiFi
DoEcho "Installing Marvel WiFi driver"
DeliverFile "wifi/usb8798_uapsta.bin" "/lib/firmware/mrvl/"
DoEcho "Installing latest network-manager"
AptInstall -d --reininstall network-manager network-manager-gnome
CheckLastResult $? "Failed installing latest network-manager"
DoEcho "Installing WICD"
AptInstall wicd-gtk
CheckLastResult $? "Failed installing wicd"
DoEcho "Uninstalling network-manager"
AptUninstall network-manager-gnome network-manager
CheckLastResult $? "Failed uninstalling network-manager"

#
## Disk
DoEcho "Installing cron job for daily disk trimming"
DeliverFile "disk/trim" "/etc/cron.daily/"
CheckLastResult $? "Failed to add trim cron job"

#
## Hibernate
DoEcho "Setting up Ubuntu to hibernate"
DeliverFile "hibernation/com.ubuntu.enable-hibernate.pkla" "/var/lib/polkit-1/localauthority/50-local.d/"
CheckLastResult $? "Failed to enable hiberate"

#
## Default Brightness
DoEcho "Dropping default brightness"
DeliverFile "power/rc.local" "/etc/"
CheckLastResult $? "Failed to change default brightness"

#
## Power Management
DoEcho "Installing some power management utilities"
AptInstall powertop
CheckLastResult $? "Failed installing powertop"
AptInstall pm-utils
CheckLastResult $? "Failed installing pm-utils"
AptInstall fancontrol
CheckLastResult $? "Failed installing fancontrol"

DeliverFile "power/99-savings" "/etc/pm/sleep.d/"
CheckLastResult $? "Failed installing power saving scripts"

#
## GINN
DoEcho "Installing ginn for some nice touch gestures!"
AptInstall ginn
CheckLastResult $? "Failed installing ginn"

DoEcho "Done, to use wifi open wicd network manager instead from your applications menu."
DoEcho "Please reboot and make sure you select the kernel marked version ${KERNEL_VERSION} from grub."

