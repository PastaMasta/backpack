#! /bin/bash

#
# Finds and checks a system for IOMMU capability
# and suggests PCI stubs / vfio
#

. /etc/init.d/functions

###############################
# IOMMU is useable

dmesg | grep -q "DMAR: IOMMU enabled"
ret=$?

action "IOMMU availible" [ $ret -eq 0 ]

if [ $ret -ne 0 ] ; then
  echo "No IOMMU detected!"
  echo "Check BIOS for IOMMU / VT-D and try again."
  exit 1
fi

###############################
# Booted from UEFI

dmesg | grep -q "UEFI"
ret=$?

action "booted from UEFI" [ $ret -eq 0 ]

if [ $ret -ne 0 ] ; then
  echo "Not booted from UEFI!"
  exit 1
fi

###############################
# Has relevent grub bits

GRUB=/etc/grub2-efi.cfg

items="
rd.driver.blacklist=nouveau
intel_iommu=on
"

for item in ${items} ; do
  grep -q ${item} ${GRUB}
  ret=$?
  action "grub ${item}" [ $ret -eq 0 ]
  if [[ $ret -ne 0 ]] ; then
    echo "${item} not in ${GRUB}"
    exit 1
  fi
done

###############################
# Find IOMMU groups

echo ""
echo "press enter to list IOMMU groups"
read

BASE="/sys/kernel/iommu_groups"
for i in $(find $BASE -maxdepth 1 -mindepth 1 -type d | sort); do
  GROUP=$(basename $i)
  echo "### Group $GROUP ###"
  for j in $(find $i/devices -type l | sort); do
    DEV=$(basename $j)
    echo -n "    "
    lspci -nns $DEV #| sed -e 's/.*\[//g' -e 's/\].*//g'
  done
done

exit $?
