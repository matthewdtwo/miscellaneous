#!/bin/bash
#
# VMware Tools Install/Upgrade Script
#
# Matthew Little - 2012
#
# This script takes care of extracting and installing vmware tools from the CD ISO image
# Mount the image on the guest and run the script from inside the guest OS.
# 

echo -en "Checking for installation requirements\t"

if [ `id -u` -ne 0 ]; then
	echo
	echo "Must be root to run the installer"
	exit 1;
fi

if [ ! -s /etc/redhat-release ]; then
	echo
	echo "Not tested on this platform"
	echo -n "Continue anyway? (Y/N): "
	read input
	if [ "$input" != "Y" ]; then
		echo "Exiting on user input"
		exit 1;
	fi
	echo -en "Checking for installation requirements\t\t"
fi

echo " [ OK ]"

# mount CDROM if not mounted

echo -en "Mounting Media\t\t\t\t"

if [ ! -d /media/cdrom ]; then
	# create mount point
	mkdir -p /media/cdrom
fi

if [ `mount | grep -c iso9660` -eq 0 ]; then
	mount -o loop /dev/cdrom /media/cdrom
fi

if [ "$?" -ne 0 ]; then
	echo "Failed"
	echo
	echo "Exiting"
	exit 1;
fi

MOUNT=`mount | grep iso9660 | awk '{print $3}'`

# check for VMwareTools
if [ `ls $MOUNT/VMwareTools* | wc -l` -ne 1 ]; then
	echo "No tools found on CD-ROM: $MOUNT"
	exit 1;
fi

echo " [ OK ]"

# unzip VMwareTools
echo -en "Unzipping VMwareTools\t\t\t"
tar xzf $MOUNT/VMwareTools*.tar.gz -C /var/tmp

if [ "$?" -ne 0 ]; then
	echo "Failed to extract tar"
	exit 1;
fi

echo " [ OK ]"

echo -n "Installing VMwareTools		"
# install vmware-tools accepting defaults, and logging to file
(/var/tmp/vmware-tools-distrib/vmware-install.pl --default ) >~/vmware-tools_upgrade.log

if [ "$?" -ne 0 ]; then
	echo "Failed to install VMwareTools"
	exit 1;
fi

echo " [ OK ]"

echo -en "Cleaning up temp directory\t\t\t"

# remove unpackaging directory
rm -rf /var/tmp/vmware-tools-distrib

if [ "$?" -ne 0 ]; then
	echo "Failed to clean up"
	exit 1;
fi

echo " [ OK ]"

echo -en "Cleaning up installer\t\t\t"
rm -f $0
echo " [ OK ]"

echo -en "Unmounting Tools\t\t\t"
umount /media/cdrom
if [ "$?" -ne 0 ]; then
	echo	
	echo "Failed to unmount tools"
else 
	rmdir /media/cdrom
	if [ "$?" -ne 0 ]; then
		echo "Failed to remove /media/cdrom"
	fi
fi

echo

echo "VMwareTools Installed"


