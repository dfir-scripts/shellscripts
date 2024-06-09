#!/bin/bash
export TZ='Etc/UTC'

#Function to produce Red Text Color
function makered() {
    COLOR='\033[01;31m' # bold red
    RESET='\033[00;00m' # normal white
    MESSAGE=${@:-"${RESET}Error: No message passed"}
    echo -e "${COLOR}${MESSAGE}${RESET}"
}
#Function to produce Green Text Color
function makegreen() {
    COLOR='\033[0;32m' # Green
    RESET='\033[00;00m' # normal white
    MESSAGE=${@:-"${RESET}Error: No message passed"}
    echo -e "${COLOR}${MESSAGE}${RESET}"
}
# reusable interactive yes-no function
function yes-no(){
      read -p "(Y/N)?"
      [ "$(echo $REPLY | tr [:upper:] [:lower:])" == "y" ] &&  yes_no="yes";
}

function grab-winfiles(){
          # Set Preferences
           makegreen "Grab a copy of forensic artifacts from a mounted Windows image or share"
           set_msource_path
           set_windir
           get_computer_name
           set_dsource_path          
           echo "#### Acquistion Log $comp_name  ####" >  $case_dir/$comp_name-Acquisition.log.txt
           # Begin Acquisition
           echo ""
           get_mft
           get_evtx
           get_registry
           get_ntuser
           get_usrclass.dat
           get_lnk_files
           get_prefetch
           get_Amcache.hve
           get_Recycle.Bin
           get_webcachev
           get_chrome
           get_firefox
           get_WMI_info
           get_srudb
           get_bits
           get_ActivitiesCache
           get_setupapi
           get_scheduled_tasks
           [ "$get_logs" ] && get_logfiles
           cd $case_dir
           tar -Prvf $case_dir/$comp_name.tar $comp_name-Acquisition.log.txt && rm $comp_name-Acquisition.log.txt
           makered "Compressing tar file to gz:"  
           makegreen "$case_dir/$comp_name.tar.gz"           
           pigz -f $case_dir/$comp_name.tar && makegreen "Data Acquisition Complete!"            
}

####### SET DATA ACQUISITION PREFERENCES #######
function set_msource_path(){
      echo ""
      makered "SET DATA SOURCE"
      echo "Set Path or Enter to Accept Default:"
      read -e -p "" -i "/mnt/image_mount/" mount_dir
      [ ! -d "${mount_dir}" ] && makered "Path does not exist.." && sleep 1 && exit
      mount_dir=$(echo $mount_dir |sed 's_.*_&\/_'|sed 's|//*|/|g')
      echo "Data Source =" $mount_dir
}

# Set Case Destination Folder (Default = /cases/)
function set_dsource_path(){
      makered "SET CASE DESTINATION FOLDER (Default = /cases/)"
      echo "Set Path or Enter to Accept:"
      read -e -p "" -i "/cases" case_dir
      [ ! -d "${case_dir}" ] && makered "Path does not exist.." && sleep 2 && exit 0
      cd $case_dir
      [ ! -d "${case_dir}" ] && makered "Path does not exist.." && sleep 1 && exit 0
}
function check_dsource_path(){
      [ -d "$triage_dir" ] && echo "$case_dir already exists! overwrite?" && yes-no && rm -r $triage_dir && quit="no"
      [ -d "$triage_dir" ] && [ "$quit" != "no" ] && exit
      mkdir -p $triage_dir
      echo "Case Folder =>  $case_dir"
}

#Find "Windows" directory paths
function set_windir(){
      cd $mount_dir
      windir=$(find $mount_dir -maxdepth 1 -type d |egrep -m1 -io windows$)
      winsysdir=$(find $mount_dir -maxdepth 2 -type d |egrep -m1 -io windows\/system32$)
      user_dir=$(find $mount_dir -maxdepth 1 -type d |grep -m1 -io users$)
      regdir=$(find $mount_dir/$winsysdir -maxdepth 2 -type d |egrep -m1 -io \/config$)
      evtxdir=$(find $mount_dir/$winsysdir -maxdepth 2 -type d |egrep -m1 -io \/winevt\/Logs$)
      [ "$windir" == "" ] || [ "$winsysdir" == "" ] && makered "No Windows Directory Path Found on Source..." && sleep 2 && exit 0
      echo "Windows System32 Directory => $mount_dir$winsysdir"
      echo  "Registry Directory" $mount_dir$winsysdir$regdir
      echo  "Windows Eventlog Directory" $mount_dir$winsysdir$evtxdir
}

#Get Computer Name using Regripper's "comp_name" plugin
function get_computer_name(){
   [ "$comp_name" == "" ] &&  \
   comp_name=$(find $mount_dir/$winsysdir/$regdir -maxdepth 1 -type f  |egrep -m1 -i /system$| while read d;
     do
       rip.pl -r "$d" -p compname 2>/dev/null |grep -i "computername   "|awk -F'= ' '{ print $2 }';done)
   [ "$comp_name" == "" ] && comp_name=$(date +'%Y-%m-%d-%H%M')
   echo "ComputerName:" $comp_name
   #cleanup and create a new new temp file to hold regripper output
   rm /tmp/$comp_name.* 2>/dev/null
   tempfile=$(mktemp /tmp/$comp_name.XXXXXXXX)
}

#Get Computer Name using Regripper's "file_name" plugin
function set_output_file(){
      now=$(date +'%Y-%m-%d-%H%M')
      echo ""
      makered "SET OUTPUT FILENAME"
      echo "Enter Output File Name or Enter to Accept Default:"
      read -e -p "" -i "winfiles-$now" file_name
      echo "Output File: $case_dir$comp_name.tar.gz"
}


##############ACQUISITION FUNCTIONS############################

#Copy Windows Journal file: USNJRNL:$J
function get_usnjrnl(){
    makegreen "Copying \$LogFile and  \$UsnJrnl:\$J"
    echo "#### USNJRNL ####" >> $case_dir/$comp_name-Acquisition.log.txt
    cd $mount_dir
    tar -Prvf $case_dir/$comp_name.tar \$Extend/\$UsnJrnl:\$J | tee -a  $case_dir/$comp_name-Acquisition.log.txt
    echo ""
    tar -Prvf $case_dir/$comp_name.tar \$LogFile | tee -a  $case_dir/$comp_name-Acquisition.log.txt
    echo ""
}

#Copy $MFT
function get_mft(){
    makegreen "Saving \$MFT "
    echo "#### MFT ####" >> $case_dir/$comp_name-Acquisition.log.txt
    cd $mount_dir
    echo $mount_dir
    tar -Prvf $case_dir/$comp_name.tar \$MFT |tee -a $case_dir/$comp_name-Acquisition.log.txt
    echo ""
}

#Copy Windows Event Logs
function get_evtx(){
    makegreen "Saving Windows Event Logs"
    echo "#### Windows Event Logs ####" >> $case_dir/$comp_name-Acquisition.log.txt
    cd $mount_dir
    find $winsysdir/[W,w]inevt/[L,l]ogs -type f 2>/dev/null -print0| \
    tar -rvf $case_dir/$comp_name.tar --null -T - |tee -a $case_dir/$comp_name-Acquisition.log.txt
    echo ""
}

#Copy Windows Registry Files
function get_registry(){
    cd $mount_dir
    makegreen "Saving Windows Registry"
    echo "#### Windows Registry ####" >> $case_dir/$comp_name-Acquisition.log.txt
    find $winsysdir/[C,c]onfig -type f  2>/dev/null -print0| \
    tar -rvf $case_dir/$comp_name.tar --null -T - |tee -a $case_dir/$comp_name-Acquisition.log.txt
    echo ""
}

#Copy User profile registry hives (NTUSER.DAT)
function get_ntuser(){
    makegreen "Saving NTUSER.DAT"
    echo "#### NTUSER.DAT ####" >> $case_dir/$comp_name-Acquisition.log.txt
    cd $mount_dir
    find $user_dir -maxdepth 2 -mindepth 2 -type f -iname "ntuser.dat" 2>/dev/null -print0| \
    tar -rvf $case_dir/$comp_name.tar --null -T - |tee -a $case_dir/$comp_name-Acquisition.log.txt
    echo ""
}

#Copy Userclass.dat files
function get_usrclass.dat(){
    makegreen "Saving usrclass.dat"
    echo "#### USRCLASS.DAT ####" >> $case_dir/$comp_name-Acquisition.log.txt
    cd $mount_dir
    find $user_dir/*/AppData/Local/Microsoft/Windows -maxdepth 2 -type f -iname "UsrClass.dat" 2>/dev/null -print0| \
    tar -rvf $case_dir/$comp_name.tar --null -T -  |tee -a $case_dir/$comp_name-Acquisition.log.txt
    echo ""
}

#Copy LNK and Jumplist file
function get_lnk_files(){
    makegreen "Saving LNK Files"
    echo "#### LNK AND JUMPLISTS ####" >> $case_dir/$comp_name-Acquisition.log.txt
    cd $mount_dir
    find $user_dir/*/AppData/Roaming/Microsoft/Windows/Recent -type f 2>/dev/null -print0| \
    tar -rvf $case_dir/$comp_name.tar --null -T -  |tee -a $case_dir/$comp_name-Acquisition.log.txt
    echo ""
}

#Copy Prefetch files
function get_prefetch(){
    makegreen "Saving Windows Prefetch"
    echo "#### PREFETCH ####" >> $case_dir/$comp_name-Acquisition.log.txt
    cd $mount_dir
    find $windir/[P,p]refetch  2>/dev/null -print0| \
    tar -rvf $case_dir/$comp_name.tar --null -T - |tee -a $case_dir/$comp_name-Acquisition.log.txt
    echo ""
}

#Copy Amcache.hve and recentfilecache.bcf
function get_Amcache.hve(){
    makegreen "Saving Amcache.hve and Recentfilecache.bcf"
    echo "#### AMCACHE.HVE AND RECENTFILECACHE.BCF ####" >> $case_dir/$comp_name-Acquisition.log.txt
    cd $mount_dir
    # Get Amcache.hve
    find $windir/[a,A]*/[P,p]* -maxdepth 1 -type f -iname "Amcache.hve" 2>/dev/null -print0| \
    tar -rvf $case_dir/$comp_name.tar --null -T - |tee -a $case_dir/$comp_name-Acquisition.log.txt
    # Get recentfilecache.bcf
    find $windir/[a,A]*/[P,p]* -maxdepth 1 -type f -iname "Recentfilecache.bcf" 2>/dev/null -print0| \
    tar -rvf $case_dir/$comp_name.tar --null -T - |tee -a $case_dir/$comp_name-Acquisition.log.txt
    echo ""
}

#Copy metadata files($I*.*) from Windows Recycle.bin
function get_Recycle.Bin(){
    makegreen "Copying RECYCLE BIN metadata ($I*.*)"
    echo "#### RECYCLEBIN $I ####" >> $case_dir/$comp_name-Acquisition.log.txt
    cd $mount_dir
    find "\$Recycle.Bin" -type f -iname "*\$I*" 2>/dev/null -print0| \
    tar -rvf $case_dir/$comp_name.tar --null -T - |tee -a $case_dir/$comp_name-Acquisition.log.txt
    echo ""
}
#Copy WebcacheV01.dat files
function get_webcachev(){
    makegreen "Saving WebcacheV01.dat"
    echo "#### MICROSOFT WEB BROWSER DB (WEBCACHEV01.DAT) ####" >> $case_dir/$comp_name-Acquisition.log.txt
    cd $mount_dir
    find $user_dir/*/AppData/Local/Microsoft/Windows/WebCache -maxdepth 2 -type f 2>/dev/null -print0| \
    tar -rvf $case_dir/$comp_name.tar --null -T -  |tee -a $case_dir/$comp_name-Acquisition.log.txt
    echo ""
}

#Copy OBJECTS.DATA and *.mof files
function get_WMI_info(){
    # Get OBJECTS.DATA file
    makegreen "Saving OBJECTS.DATA and Mof files"
    echo "#### OBJECTS.DATA AND MOF ####" >> $case_dir/$comp_name-Acquisition.log.txt
    cd $mount_dir
    find $winsysdir/[W,w][B,b][E,e][M,m] -maxdepth 2 -type f  -iname "OBJECTS.DATA" 2>/dev/null -print0| \
    tar -rvf $case_dir/$comp_name.tar --null -T - |tee -a $case_dir/$comp_name-Acquisition.log.txt
    # Get all Mof files
    find $winsysdir/[W,w][B,b][E,e][M,m]/*/ -maxdepth 2 -type f -iname "*.mof" 2>/dev/null -print0| \
    tar -rvf $case_dir/$comp_name.tar --null -T - |tee -a $case_dir/$comp_name-Acquisition.log.txt
    echo ""
}

#Copy SRUDB.dat
function get_srudb(){
    cd $mount_dir
    makegreen "Saving SRUDB.DAT"
    echo "#### SRUDB.DAT ####" >> $case_dir/$comp_name-Acquisition.log.txt
    find $winsysdir/[S,s][R,r][U,u]/ -maxdepth 1 -mindepth 1 -type f 2>/dev/null -print0|\
    tar -rvf $case_dir/$comp_name.tar --null -T - |tee -a $case_dir/$comp_name-Acquisition.log.txt
    echo ""
}

function get_bits(){
    cd $mount_dir
    makegreen "Saving qmgr.db"
    echo "#### QMGR.DB ####" >> $case_dir/$comp_name-Acquisition.log.txt
    find ProgramData/Microsoft/Network/Downloader -maxdepth 1 -mindepth 1 -type f 2>/dev/null -print0|\
    tar -rvf $case_dir/$comp_name.tar --null -T - |tee -a $case_dir/$comp_name-Acquisition.log.txt
    echo ""
}

#Copy ActivitiesCache.db
function get_ActivitiesCache(){
    cd $mount_dir
    makegreen "Saving ActivitiesCache.db"
    echo "#### ActivitiesCache.db ####" >> $case_dir/$comp_name-Acquisition.log.txt
    find $user_dir/*/AppData/Local/ConnectedDevicesPlatform/ -maxdepth 2 -mindepth 1 -type f -iname "ActivitiesCache*" 2>/dev/null -print0|\
    tar -rvf $case_dir/$comp_name.tar --null -T - |tee -a $case_dir/$comp_name-Acquisition.log.txt
    echo ""
}


#Copy Setupapi logs
function get_setupapi(){
    cd $mount_dir
    makegreen "Saving Setupapi.dev.log"
    echo "#### SETUPAPI LOG FILES ####" >> $case_dir/$comp_name-Acquisition.log.txt
    find $windir/[I,i][N,n][F,f] -type f -iname "setupapi*log" 2>/dev/null -print0| \
    tar -rvf $case_dir/$comp_name.tar --null -T - |tee -a $case_dir/$comp_name-Acquisition.log.txt
    echo ""
}

#Copy Scheduled Tasks
function get_scheduled_tasks(){
    makegreen "Saving Scheduled Tasks List"
    echo "#### SCHEDULED TASKS ####" >> $case_dir/$comp_name-Acquisition.log.txt
    cd $mount_dir
    #Tasks dir in Windows directory
    find $windir/[t,T]asks -type f 2>/dev/null -print0| \
    tar -rvf $case_dir/$comp_name.tar --null -T - |tee -a $case_dir/$comp_name-Acquisition.log.txt
    #Tasks dir in Windows/System32 directories
    find $winsysdir/[t,T]asks -type f 2>/dev/null -print0| \
    tar -rvf $case_dir/$comp_name.tar --null -T - |tee -a $case_dir/$comp_name-Acquisition.log.txt
}

#Copy Windows log files
function get_logfiles(){
    makegreen "Saving Windows Log Files" && \
    echo "#### WINDOWS LOGFILES ####" >> $case_dir/$comp_name-Acquisition.log.txt
    find -maxdepth 1 -type d  -iname "inetpub" 2>/dev/null -print0| \
    tar -rvf $case_dir/$comp_name.tar --null -T - |tee -a $case_dir/$comp_name-Acquisition.log.txt
    find $winsysdir -maxdepth 2 -type d -iname "LogFiles" -print0| \
    tar -rvf $case_dir/$comp_name.tar --null -T - |tee -a $case_dir/$comp_name-Acquisition.log.txt
    echo ""
}

#Copy Chrome metadata
function get_chrome(){
     makegreen "Copying CHROME and Brave Metadata"
    echo "#### CHROME / BRAVE ####" >> $case_dir/$comp_name-Acquisition.log.txt
    cd $mount_dir
    find $user_dir/*/AppData/Local/*/*/User\ Data/Default -maxdepth 2 -type f \
    \( -name "History" -o -name "Bookmarks" -o -name "Cookies" -o -name "Favicons" -o -name "Web\ Data" \
    -o -name "Login\ Data" -o -name "Top\ Sites" -o -name "Current\ *" -o -name "Last\ *" \)  2>/dev/null -print0| \
    tar -rvf $case_dir/$comp_name.tar --null -T - |tee -a $case_dir/$comp_name-Acquisition.log.txt
    echo ""
}

#Copy Firefox Metadata
function get_firefox(){
    makegreen "Copying FIREFOX Metadata"
    echo "#### FIREFOX ####" >> $case_dir/$comp_name-Acquisition.log.txt
    cd $mount_dir
    find $user_dir/*/AppData/Roaming/Mozilla/Firefox/Profiles/*/ -maxdepth 2 -type f \
    \( -name "*.sqlite" -o -name "logins.json" -o -name "sessionstore.jsonlz4" \)  2>/dev/null -print0| \
    tar -rvf $case_dir/$comp_name.tar --null -T - |tee -a $case_dir/$comp_name-Acquisition.log.txt
    echo ""
}
########END DATA ACQUISITION FUNCTIONS######

clear
[ $(whoami) != "root" ] && makered "Requires Root!" && exit
echo grabwinfiles.sh
which pigz &>/dev/null && grab-winfiles || makered "Exiting pigz is required.  Install and try again!"
