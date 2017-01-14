#!/bin/bash
## 
# Mounts E01 and raw disk images 
# Requirements: mmls and mount commands
#https://github.com/siftgrab/shellscripts
# ~jsbrown
## Menu Option Seleted (Red output)
EWFMNT="/mnt/ewf"
WINMNT="/mnt/windows_mount"
function makered() {
    COLOR='\033[01;31m' # bold red
    RESET='\033[00;00m' # normal white
    MESSAGE=${@:-"${RESET}Error: No message passed"}
    echo -e "${COLOR}${MESSAGE}${RESET}"
}

function makegreen() {
    COLOR='\033[1;32m' # Green
    RESET='\033[00;00m' # normal white
    MESSAGE=${@:-"${RESET}Error: No message passed"}
    echo -e "${COLOR}${MESSAGE}${RESET}"
}

# Identify and set mount points 
function mount_prefs(){
makered "IMAGE FILE TO MOUNT"      
      read -e -p "Image File:" -i "" IPATH
      [ -f "${IPATH}" ] || makered "File does not exist"
      [ -f "${IPATH}" ] || exit
      IMG_TYPE=$(echo "$IPATH"|awk -F . '{print $NF}')
      [ $IMG_TYPE == "E01" ] &&  SRC_DST="/mnt/ewf/ewf1 /mnt/windows_mount" || SRC_DST=""${IPATH}" /mnt/windows_mount" 

      makered "FILE SYSTEM TYPE"
      echo "Defaults is ntfs, see mount man pages for other options"
      read -e -p "File System:" -i "ntfs" FSTYPE
      [ $FSTYPE == "ntfs" ] && ntfs_support=",show_sys_files,streams_interface=windows" 
      
      # run mmls
      makered "INVOKING MMLS"
      sudo mmls "${IPATH}" 
      read -e -p "Enter the starting block: "  SBLOCK
      read -e -p "Set disk block size:  " -i "512" BSIZE
      echo ""
      OFFSET=$(echo $(($SBLOCK * $BSIZE)))
      makegreen "CALCULATING STARTING OFFSET: $SBLOCK * $BSIZE = $OFFSET"
      makegreen "STARTING OFFSET IS:  $OFFSET"   
      read -n1 -r -p "Press any key..." key
}
# Check Mount status for /mnt/windows_mount and /mnt/ewf
function mount_status(){
      [ -e /mnt/windows_mount ] && MNT_STAT="1"
      sudo [ -e /mnt/ewf ] && MNT_STAT="1"
      
      [ $MNT_STAT == "1" ]  && makered "TARGET MOUNT POINT(S) ARE IN USE:" && findmnt -m|grep '/mnt/ewf\|/mnt/windows_mount' || mount_image
      read -p "umount? (Y/N)?"
      [ "$(echo $REPLY | tr [:upper:] [:lower:])" == "y" ] && mount_image || echo "mount command(s) ignored" && makered "sudo mount -t $FSTYPE -o ro,loop$ntfs_support,offset=$OFFSET $SRC_DST" && [ $IMG_TYPE == "E01" ] && makered "sudo mount_ewf.py "${IPATH}" /mnt/ewf" &&  exit
}

# Mount E01 or raw image
function mount_image(){
      [ -e /mnt/windows_mount ] && sudo umount /mnt/windows_mount  && echo "unmounting /mnt/windows_mount"
      sudo  [ -e /mnt/ewf/ewf1 ] && sudo umount /mnt/ewf && echo "unmounting /mnt/ewf/ewf1"
      [ -e /mnt/windows_mount ] &&  sudo [ -e /mnt/ewf ] && echo "unmount success!" || echo "unmount failed"
      sleep 4
      [ $IMG_TYPE == "E01" ] && sudo mount_ewf.py "${IPATH}" /mnt/ewf  
      # Raw disk mount
      echo "MOUNTING THE DISK IMAGE....."
      makered "sudo mount -t $FSTYPE -o ro,loop$ntfs_support,offset=$OFFSET $SRC_DST" 
      sudo mount -t $FSTYPE -o ro,loop$ntfs_support,offset=$OFFSET $SRC_DST 
      echo ""
      echo ""
      echo "DIRECTORY LISTING OF MOUNTED IMAGE:  /mnt/windows_mnt"
      ls /mnt/windows_mount
      echo ""
      echo ""
      [ "$(ls -A /mnt/windows_mount)" ] && makegreen "IMAGE SUCCESSFULLY MOUNTED!" || makered "IMAGE DID NOT MOUNT!"
      exit
}
# Start
clear
makegreen "EZ Mounting of E01 or RAW disk image files"
mount_prefs
mount_status
