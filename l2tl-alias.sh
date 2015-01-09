#!/bin/bash
## Command line builder for log2timeline.pl
# Mounts E01 and raw disk images on the fly
# Relies on tools and directories which are part of the SANS SiFT 3.0 Distribution
#https://github.com/siftgrab/shellscripts
# ~jsbrown
## Menu Option Seleted (Red output)
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

# Sets a name to identify this timeline.
function set_TL_name(){
 DDIR=$(date +'%Y-%m-%d-%H%M')
      makered "SET TIMELINE NAME:" 
      read -e -p "TIMELINE NAME=   " -i "$(echo $PWD"/Timeline-"$DDIR)" OPATH  
      clear
}
# Select input module that matches the data you want to process.
function set_OS_type(){
L2TL=log2timeline
echo "Select input module that matches the data you want to process:"
      echo "Separate multiples with comma, type \"help\" to choose from a list all available input modules"
      echo ""
      echo "linux  winsrv  win7   winxp   macosx"
      echo ""
      makered "SET INPUT MODULE(s)"; 
      read -e -p "INPUT MODULE(S)=  " -i "win7" OSTYPE
      [ $OSTYPE == "help" ] && echo "$IPLUGINS" && read -e -p "ENTER INPUT MODULE(S):  " -i "" OSTYPE
      clear
}
#Set input path for Log2timeline to a data directory or a mounted image.
function set_l2tl_path(){
[ -f "$IPATH" ] && IPATH="/mnt/windows_mount"
      echo "Set path to an image mount point, directory or artifact"      
      echo ""
      echo "examples...."
      echo "/mnt/hgfs/artifacts/WS-122015-mft.mft"   
      echo "/mnt/windows_mount"  
      echo ""
      makered "ENTER DATA INPUT PATH";
      read -e -p "INPUT PATH= " -i "" IPATH
      clear
}

#Set TimeZone 
function set_timezone(){
echo "Enter new TimeZone value or accept UTC/ETC:"
      # "Run \"log2timeline -z list\" for a complete list"
      echo ""
      echo "Common Values:"
      echo "EST5EDT CST6CDT MST7MDT  PST8PDT  Etc/UTC"
      echo ""
      makered "SET THE TIMEZONE: ";
      read -e -p "ENTER THE TIMEZONE= " -i "Etc/UTC" TLTZ
      clear
}

#Set log2timeline output file format type.
function set_oformat_type(){
echo "Enter desired output format value or accept csv:"
echo "--------------------------------------------------------------
Name	Version		Description
--------------------------------------------------------------
csv	 0.7	Output data into a CSV file
mactime	 0.7	Timeline using mactime format
simile	 0.5	XML output readable by a SIMILE widget
sqlite	 0.9	Dump data into a SQLite database
tab	 0.2	Output as a TDV (Tab Delimited Value)
tln	 0.7	Output using H. Carvey's TLN format
tlnx	 0.2	Output H. Carvey's TLN format in XML
beedocs	 0.2	Format for import into BeeDocs
cef	 0.3	Output data into ArcSight CEF
cftl	 0.7	XML that can be read by CFTL
mactime_l	 0.7	Legacy mactime format
serialize	 0.1	Save using a serialized object."
      echo ""
      makered "ENTER IMAGE OUTPUT FILE FORMAT";      
      read -e -p "ENTER OUTPUT FILE FORMAT= " -i "csv" OFORMAT
      clear
}

#Set Recursion and Preprocessor 
function set_recursion(){
makered "Set recursive and preprocessor options for a mounted image or a  directory?";
      read -p "Perform a recursive search for files to process  (Y/N)?"
      [ "$(echo $REPLY | tr [:upper:] [:lower:])" == "y" ] && RECURSE="-r "; 
      read -p "Enable preprocessing for a mounted disk image  (Y/N)?"
      [ "$(echo $REPLY | tr [:upper:] [:lower:])" == "y" ] && PREPROC="-p "; 
      clear
}

#Available Input Modules
IPLUGINS=$(
echo "
linux  (group)
apache2_access, apache2_error, pcap, syslog, generic_linux, proftpd_xferlog, chrome, safari, firefox3, selinux, utmp

macosx  (group) 
apache2_access, apache2_error, syslog, syslog, generic_linux, proftpd_xferlog, ff_bookmark, firefox2, firefox3, ls_quarantine, mcafeefireup, mcafeehel, mcafeehs, openvpn, opera, oxml, pdf, safari, skype_sql, sol, symantec 

webhist  (group)
chrome, firefox3, firefox2, ff_bookmark, opera, iehistory, iis, safari, sol, 

win7 (group)
chrome,evtx,exif,ff_bookmark,firefox3,iehistory,iis,mcafee,opera,oxml,pdf,prefetch,recycler,restore,sol,win_link,xpfirewall,wmiprov,ntuser,software,system,sam,mft,ff_cache,mcafeefireup,mcafeehel,mcafeehs,openvpn,skype_sql,security,symantec,firefox2,safari) 

win7_no_reg  (group)
chrome, evtx, exif, ff_bookmark, firefox3, iehistory, iis, mcafee, opera, oxml, pdf, prefetch, recycler, restore, sol, ntuser, win_link, xpfirewall, wmiprov, mft, ff_cache, mcafeefireup, mcafeehel, mcafeehs, openvpn, skype_sql, security, symantec, firefox2, safari
 
winsrv   (group)
evt, exif, iis, isatxt, mcafee, pdf, prefetch, recycler, restore, setupapi, win_link, xpfirewall, wmiprov, ntuser, software, system, apache2_access, apache2_error, mft, mssql_errlog, 

winxp   (group)
chrome, evt, exif, ff_bookmark, firefox3, iehistory, iis, mcafee, opera, oxml, pdf, prefetch, recycler, restore, setupapi, sol, win_link, xpfirewall, wmiprov, ntuser, software, system, sam, mft, ff_cache, mcafeefireup, mcafeehel, mcafeehs, openvpn, skype_sql, security, symantec, firefox2, safari, 

winxp_no_reg   (group)
chrome, evt, exif, ff_bookmark, firefox3, iehistory, iis, mcafee, opera, oxml, pdf, prefetch, recycler, restore, setupapi, sol, ntuser, win_link, xpfirewall, wmiprov, mft, ff_cache, mcafeefireup, mcafeehel, mcafeehs, openvpn, skype_sql, security, symantec, firefox2, safari,

windows_all (group)
chrome, evt, evtx, exif, ff_bookmark, firefox3, iehistory, iis, mcafee, opera, oxml, pdf, prefetch, recycler, restore, sol, win_link, xpfirewall, wmiprov, ntuser, software, system, sam, mft, ff_cache, mcafeefireup, mcafeehel, mcafeehs, openvpn, skype_sql, security, symantec, firefox2, safari, isatxt, apache2_access, apache2_error, mssql_errlog, 

---------------------------------------------------------------------------------------------------------
Input Modules can be set to run predefined module groups (i.e. linux, win7, macosx, webhist) 
or can be called individually or in multiples by entering module names separated by commas with no spaces                  
---------------------------------------------------------------------------------------------------------

")

# mount an E01 or Raw disk image and identify partition to mount
function mount_image(){
makered "Enter path and name of E01 or raw disk image file"      
      read -e -p "INPUT PATH:" -i "" IPATH
      [ -f "$IPATH" ] || makered "ERROR: file does not exist"
      [ -f "$IPATH" ] || exit
      IMG_NAME=$(echo "$IPATH"|awk -F / '{print $NF}')
      IMG_TYPE=$(echo "$IPATH"|awk -F . '{print $NF}')
      IMG_BASENAME=$(echo "$IMG_NAME"|awk -F . '{print $1}')
      # E01 disk mount
      [ $IMG_TYPE == "E01" ] && [ -e /mnt/ewf ] || sudo umount /mnt/windows_mount && sudo umount /mnt/ewf && sudo ls /mnt/ewf 
      [ $IMG_TYPE == "E01" ] && read -n1 -r -p "Attempting to mount E01 disk image $IMG_NAME ... Press any key to continue" key && sudo mount_ewf.py $IPATH /mnt/ewf && sudo ls /mnt/ewf 
      # run mmls
      echo ""
      echo ""
      clear
      makered "LETS RUN mmls TO CALCULATE THE OFFSET USING THE STARTING BLOCK AND BLOCK SIZE!"  
      echo ""    
      IMG_BASENAME=$(sudo ls /mnt/ewf)     
      [ $IMG_TYPE == "E01" ] && sudo mmls /mnt/ewf/$IMG_BASENAME || mmls $IPATH  
      read -e -p "Enter the starting block of the partition you want to mount: "  SBLOCK
      read -e -p "Enter disk block size based on mmls output:  " -i "512" BSIZE
      echo ""
      OFFSET=$(echo $(($SBLOCK * $BSIZE)))
      makegreen "CALCULATING: $SBLOCK * $BSIZE = $OFFSET"
      makegreen "STARTING OFFSET:  $OFFSET"   
      read -n1 -r -p "Press any key to continue..." key
      # Raw disk mount
      [ -e /mnt/windows_mount ] || sudo umount /mnt/windows_mount 
      echo "MOUNTING THE DISK IMAGE....."
      [ $IMG_TYPE == "E01" ] && makered "sudo mount -t ntfs -o ro,loop,show_sys_files,streams_interface=windows,offset=$OFFSET /mnt/ewf/$IMG_BASENAME /mnt/windows_mount" || makered "sudo mount -t ntfs -o ro,loop,show_sys_files,streams_interface=windows,offset=$OFFSET $IPATH /mnt/windows_mount"
      [ $IMG_TYPE == "E01" ] && sudo mount -t ntfs -o ro,loop,show_sys_files,streams_interface=windows,offset=$OFFSET /mnt/ewf/$IMG_BASENAME /mnt/windows_mount || sudo mount -t ntfs -o ro,loop,show_sys_files,streams_interface=windows,offset=$OFFSET $IPATH /mnt/windows_mount
      echo ""
      echo ""
      echo "DIRECTORY LISTING OF MOUNTED IMAGE:  /mnt/windows_mnt"
      ls /mnt/windows_mount
      echo ""
      echo ""
      [ "$(ls -A /mnt/windows_mount)" ] && makegreen "IMAGE SUCCESSFULLY MOUNTED!" && makegreen "Set Input Path to:"  && makered "/mnt/windows_mount" || makered "IMAGE DID NOT MOUNT!"
      echo ""
      echo ""
      echo ""
      read -n1 -r -p "Press any key to proceed..." key
}
# Start
clear
makegreen "LOG2TIMELINE COMMAND BUILDER"
echo ""
read -p "Do you have a partition located on an E01 or raw disk image file?(Y/N)?"
[ "$(echo $REPLY | tr [:upper:] [:lower:])" == "y" ] && mount_image;
clear
makegreen "LOG2TIMELINE COMMAND BUILDER"
echo ""
set -e
set_TL_name
makegreen "LOG2TIMELINE COMMAND BUILDER"
echo "----------------------------"
makegreen "TIMELINE NAME:    $OPATH.$OFORMAT"
makegreen ""
makegreen ""
makegreen ""
set_OS_type
makegreen "LOG2TIMELINE COMMAND BUILDER"
echo "----------------------------"
makegreen "TIMELINE NAME:    $OPATH.$OFORMAT"
makegreen "INPUT MODULE(S):  $OSTYPE"
echo ""
echo ""
echo ""
set_l2tl_path
makegreen "LOG2TIMELINE COMMAND BUILDER"
echo "----------------------------"
makegreen "TIMELINE NAME:    $OPATH.$OFORMAT"
makegreen "INPUT MODULE(S):  $OSTYPE"
makegreen "DATA SOURCE PATH: $IPATH"
echo ""
echo ""
echo ""
set_timezone
makegreen "LOG2TIMELINE COMMAND BUILDER"
echo "----------------------------"
makegreen "TIMELINE NAME:    $OPATH.$OFORMAT"
makegreen "INPUT MODULE(S):  $OSTYPE"
makegreen "DATA SOURCE PATH: $IPATH"
makegreen "TIMEZONE SETTING: $TLTZ"
echo ""
set_oformat_type
makegreen "LOG2TIMELINE COMMAND BUILDER"
echo "----------------------------"
makegreen "TIMELINE NAME:    $OPATH.$OFORMAT"
makegreen "INPUT MODULE(S):  $OSTYPE"
makegreen "DATA SOURCE PATH: $IPATH"
makegreen "TIMEZONE SETTING: $TLTZ"
makegreen "TIMELINE FORMAT:  $OFORMAT" 
echo ""
echo ""
echo ""
set_recursion
makegreen "LOG2TIMELINE COMMAND BUILDER"
echo "----------------------------"
makegreen "TIMELINE NAME:        $OPATH.$OFORMAT"
makegreen "INPUT MODULE(S):      $OSTYPE"
makegreen "DATA SOURCE PATH:     $IPATH"
makegreen "TIMEZONE SETTING:     $TLTZ"
makegreen "TIMELINE FORMAT:      $OFORMAT" 
[ "$RECURSE" != "" ] && RS="ENABLED" ||  RS="NO"
makegreen "RECURSIVE PROCESSING: $RS" 
[ "$PREPROC" != "" ] && PP="ENABLED" || PP="NO"
makegreen "PREPROCESSOR:         $PP"
makegreen "DETAIL:               ENABLED" 
echo ""
echo ""
echo ""
L2TL="log2timeline -z $TLTZ -d $PREPROC$RECURSE-f $OSTYPE $IPATH"
makered "LOG2TIMELINE COMMAND CREATED:" 
echo ""
echo "$L2TL -w $OPATH.$OFORMAT"
echo ""
read -p "Would you like to run this command (Y/N)?"
[ "$(echo $REPLY | tr [:upper:] [:lower:])" == "y" ] || exit; 
[ -f "$IPATH" ] || [ -d "$IPATH" ] || makered "ERROR: Invalid image, file or path!"
[ -f "$IPATH" ] || [ -d "$IPATH" ] || exit
[ -d $OPATH ] || mkdir $OPATH           
$L2TL -w $OPATH.$OFORMAT
echo ""
makegreen "   Timeline Results file:"
makegreen "   $OPATH"
read -n1 -r -p "   Press any key to continue..." key
