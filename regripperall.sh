#!/bin/bash
# Regripper extractor
# Searches mounted NTFS volumes, directories for registry hives and uses regripper to extracts output to TLN and text files to a directory based on computer name.  Can alternatively be used on single registry hives
 
#Get Computer Name using Regripper's "comp_name" plugin
function get_computer_name(){
   comp_name=$(find $reg_dir -maxdepth 1 -type f 2>/dev/null |egrep -m1 -i \/system$| while read d;
     do
       rip.pl -r "$d" -p compname 2>/dev/null |grep -i "computername   "|awk -F'= ' '{ print $2 }';done)
   [ "$comp_name" == "" ] && comp_name=$(date +'%Y-%m-%d-%H%M')
}

#Create Output Directories
function create_output_dir(){
output_dirs=("System_Info/Software" "System_Info/Network" "System_Info/Settings" "Account_Usage" "File_Access" "Program_Execution"  "NTUSER" "USB_Access" "Persistence" "User_Searches" "Timeline" "Alert")
    for dir_name in "${output_dirs[@]}";
    do
      mkdir -p $out_dir/$comp_name/$dir_name
    done
}
function create_users_dir(){
  find "$ntuser_dirs/" -maxdepth 2 ! -type l 2>/dev/null|grep -i ntuser.dat$ |while read ntuser_path;
    do
      user_name=$( echo "$ntuser_path"|sed 's/\/$//'|awk -F"/" '{print $(NF-1)}')
      mkdir -p "$out_dir/$comp_name/NTUSER/$user_name"
    done
}

######### PROCESSING FUNCTIONS##############

#Run select RegRipper plugins on Software Registry
function rip_software(){
    cd $out_dir/$comp_name
    find $reg_dir -maxdepth 1 -type f 2>/dev/null | grep -i "\/software$"| while read d;
    do
      echo "Running select RegRipper plugins on the Software Registry Hive(s)"
      rip.pl -r "$d" -p winver |tee -a $out_dir/$comp_name/System_Info/Windows_Version_Info-$comp_name.txt;  # winnt_cv
      rip.pl -r "$d" -p lastloggedon |tee -a $out_dir/$comp_name/Account_Usage/Last-Logged-On-$comp_name.txt;
      rip.pl -r "$d" -p networklist 2>/dev/null |tee -a $out_dir/$comp_name/System_Info/Network/Network-List-$comp_name.txt;
      rip.pl -r "$d" -p profilelist 2>/dev/null |tee -a $out_dir/$comp_name/Account_Usage/User-Profiles-$comp_name.txt;
      rip.pl -r "$d" -p pslogging 2>/dev/null |tee -a $out_dir/$comp_name/System_Info/Settings/Powershell-logging-$comp_name.txt;
      rip.pl -r "$d" -p clsid 2>/dev/null |tee -a $out_dir/$comp_name/System_Info/Settings/Clsid-logging-$comp_name.txt;
      rip.pl -r "$d" -p portdev |tee -a $out_dir/$comp_name/USB_Access/USB_Device_List-$comp_name.txt;
      rip.pl -r "$d" -p runonceex |grep -va "^$"|tee -a $out_dir/$comp_name/Persistence/Run-Once-$comp_name.txt;
      rip.pl -r "$d" -p appcertdlls |grep -va "^$"|tee -a $out_dir/$comp_name/Persistence/Appcertsdlls-$comp_name.txt;
      rip.pl -r "$d" -p appinitdlls |grep -va "^$"|tee -a $out_dir/$comp_name/Persistence/AppInitdlls-$comp_name.txt;
      rip.pl -r "$d" -p dcom |grep -va "^$"|tee -a $out_dir/$comp_name/Persistence/ports-$comp_name.txt;
      rip.pl -r "$d" -p psscript |grep -va "^$"|tee -a $out_dir/$comp_name/Persistence/Powershell-Script-$comp_name.txt;
      rip.pl -r "$d" -p listsoft |grep -va "^$"|tee -a $out_dir/$comp_name/System_Info/Software/Software-Installed-$comp_name.txt;
      rip.pl -r "$d" -p msis |grep -va "^$"|tee -a $out_dir/$comp_name/System_Info/Software/Msiexec-Installs-$comp_name.txt;
      rip.pl -r "$d" -p uninstall |grep -va "^$"|tee -a $out_dir/$comp_name/System_Info/Software/Add-Remove-Programs-$comp_name.txt;
      rip.pl -r "$d" -p netsh |grep -va "^$"|tee -a $out_dir/$comp_name/System_Info/Settings/Netsh-$comp_name.txt;
      rip.pl -r "$d" -p srum |grep -va "^$"|tee -a $out_dir/$comp_name/Program_Execution/Srum-$comp_name.txt;
      rip.pl -r "$d" -p run |grep -va "^$"|tee -a $out_dir/$comp_name/Persistence/Autorun-$comp_name.txt;
      rip.pl -r "$d" -f software |grep -va "^$"|tee -a $out_dir/$comp_name/SOFTWARE-$comp_name.txt;
    done
    # rip all tlns to $out_dir/$comp_name/Timeline/Regripper-Timeline-$comp_name.TLN
    find $reg_dir -maxdepth 1 -type f 2>/dev/null | grep -i "\/software$"| while read d;
    do
      rip.pl -aT -r $d |sed "s/|||/|${comp_name}|${user_name}|/" |grep ".*|.*|.*|.*|.*" | tee -a  $out_dir/$comp_name/Timeline/Regripper-Timeline-$comp_name.TLN
    done
}

#Run select RegRipper plugins on the System Registry
#######"System_Info/Software" "System_Info/Network" "System_Info/Settings" "Account_Usage"
function rip_system(){
    cd $out_dir/$comp_name
    find $reg_dir -maxdepth 1 -type f 2>/dev/null | grep -i -m1 "\/system$"| while read d;
    do
      echo "Running select RegRipper plugins on the System Registry Hive(s)"    
      rip.pl -r "$d" -p nic2 |tee -a $out_dir/$comp_name/System_Info/Network/Last-Networks-$comp_name.txt;
      rip.pl -r "$d" -p shares |tee -a $out_dir/$comp_name/System_Info/Network/Network-Shares-$comp_name.txt;
      rip.pl -r "$d" -p shimcache |tee -a $out_dir/$comp_name/Program_Execution/Shimcache-$comp_name.txt;
      rip.pl -r "$d" -p usbstor |tee -a $out_dir/$comp_name/USB_Access/USBStor-$comp_name.txt;
      rip.pl -r "$d" -p backuprestore |tee -a $out_dir/$comp_name/System_Info/Settings/Not-In-VSS-$comp_name.txt;
      rip.pl -r "$d" -p ntds |tee -a $out_dir/$comp_name/Persistence/ntds-$comp_name.txt;
      rip.pl -r "$d" -p devclass |tee -a $out_dir/$comp_name/USB_Access/USBdesc-$comp_name.txt;
      rip.pl -r "$d" -p lsa |tee -a $out_dir/$comp_name/System_Info/Settings/Lsa-$comp_name.txt;
      rip.pl -r "$d" -p rdpport |tee -a $out_dir/$comp_name/System_Info/Settings/RDP-Port-$comp_name.txt;
      rip.pl -r "$d" -p remoteaccess |tee -a $out_dir/$comp_name/System_Info/Settings/Remote-Access-Lockout-$comp_name.txt;
      rip.pl -r "$d" -p routes |tee -a $out_dir/$comp_name/System_Info/Network/Routes-$comp_name.txt;
      rip.pl -r "$d" -f system |tee -a $out_dir/$comp_name/SYSTEM-$comp_name.txt;
    done
    find $reg_dir -maxdepth 1 -type f 2>/dev/null | grep -i "\/system$"| while read d;
    do
      rip.pl -aT -r $d |sed "s/|||/|${comp_name}|${user_name}|/"|grep ".*|.*|.*|.*|.*" | tee -a  $out_dir/$comp_name/Timeline/Regripper-Timeline-$comp_name.TLN
    done
}

#Run select RegRipper plugins on the Security Registry
function rip_security(){
    cd $out_dir/$comp_name
    find $reg_dir -maxdepth 1 -type f 2>/dev/null | grep -m1 -i "\/security$"| while read d;
    do
      echo "Running select RegRipper plugins on the Security Registry Hive(s)"    
      rip.pl -r $d -p auditpol 2>/dev/null |tee -a $out_dir/$comp_name/System_Info/Settings/Audit-Policy-$comp_name.txt;
      rip.pl -r $d -f security 2>/dev/null |tee -a $out_dir/$comp_name/SECURITY-$comp_name.txt;
    done
    find $reg_dir -maxdepth 1 -type f 2>/dev/null | grep -i "\/security$" | while read d;
    do
      rip.pl -aT -r $d |sed "s/|||/|${comp_name}|${user_name}|/" |grep ".*|.*|.*|.*|.*" | tee -a  $out_dir/$comp_name/Timeline/Regripper-Timeline-$comp_name.TLN
    done
}

#Run all RegRipper plugins on NTUSER.DAT and Usrclass.dat
function regrip_ntuser_usrclass(){
    find "$ntuser_dirs" -maxdepth 2 ! -type l 2>/dev/null|grep -i ntuser.dat$ |while read ntuser_path;
    do
      user_name=$(echo "$ntuser_path"|sed 's/\/$//'|awk -F"/" '{print $(NF-1)}')
      usrclass_file=$(find $ntuser_dirs/"$user_name"/[aA]*[aA]/[lL]*[lL]/[mM][iI]*[tT]/[wW]*[sS] -maxdepth 3 -type f 2>/dev/null|grep -i -m1 "\/usrclass.dat$")
      rip.pl -r "$ntuser_path" -a |tee -a "$out_dir/$comp_name/NTUSER/$user_name/$comp_name-$user_name-NTUSER.txt"
      rip.pl -aT -r "$ntuser_path" |sed "s/|||/|${comp_name}|${user_name}|/" | grep ".*|.*|.*|.*|.*" | tee -a  $out_dir/$comp_name/Timeline/Regripper-Timeline-$comp_name.TLN
      rip.pl -r "$usrclass_file" -a |tee -a "$out_dir/$comp_name/NTUSER/$user_name/$comp_name-$user_name-USRCLASS.txt"
      rip.pl -aT -r "$usrclass_file" |sed "s/|||/|${comp_name}|${user_name}|/" | grep ".*|.*|.*|.*|.*" | tee -a  $out_dir/$comp_name/Timeline/Regripper-Timeline-$comp_name.TLN
    done
}

#Run Select Regripper plugins on NTUSER.DAT
function regrip_user_plugins(){
    cd $ntuser_dirs
    find $ntuser_dirs -maxdepth 2 ! -type l 2>/dev/null|grep -i ntuser.dat$ |while read ntuser_path;
    do
      echo "Searching for NTUSER.DAT KEYS (Regripper)"
      user_name=$( echo "$ntuser_path"|sed 's/\/$//'|awk -F"/" '{print $(NF-1)}')
      rip.pl -r "$ntuser_path" -p userassist |tee -a "$out_dir/$comp_name/Program_Execution/UserAssist-$user_name-$comp_name.txt"
      rip.pl -r "$ntuser_path" -p recentdocs |tee -a "$out_dir/$comp_name/File_Access/$user_name-RecentDocuments-$comp_name.txt"

      echo "######  "$user_name"  ######" |tee -a "$out_dir/$comp_name/User_Searches/ACMRU-$comp_name.txt"
      rip.pl -r "$ntuser_path" -p runmru |grep -va "^$"|tee -a "$out_dir/$comp_name/Program_Execution/Run-MRU-$comp_name.txt"

      echo "######  "$user_name"  ######" |tee -a "$out_dir/$comp_name/File_Access/opened-saved-$comp_name.txt"
      rip.pl -r "$ntuser_path" -p comdlg32 |grep -va "^$"|tee -a "$out_dir/$comp_name/File_Access/opened-saved-$comp_name.txt"

      echo "######  "$user_name"  ######" |tee -a "$out_dir/$comp_name/User_Searches/Wordwheel-$comp_name.txt"
      rip.pl -r "$ntuser_path" -p wordwheelquery |grep -va "^$"|tee -a "$out_dir/$comp_name/User_Searches/Wordwheel-$comp_name.txt"

      echo "######  "$user_name"  ######" |tee -a "$out_dir/$comp_name/User_Searches/Typedpaths-$comp_name.txt"
      rip.pl -r "$ntuser_path" -p typedpaths |grep -va "^$"|tee -a "$out_dir/$comp_name/User_Searches/Typedpaths-$comp_name.txt"

      echo "######  "$user_name"  ######" |tee -a "$out_dir/$comp_name/User_Searches/Typedurls-$comp_name.txt"
      rip.pl -r "$ntuser_path" -p typedurls |grep -va "^$"|tee -a "$out_dir/$comp_name/User_Searches/Typedurls-$comp_name.txt"

      echo "######  "$user_name"  ######" |tee -a "$out_dir/$comp_name/User_Searches/Typedurlstime-$comp_name.txt"
      rip.pl -r "$ntuser_path" -p typedurlstime |grep -va "^$"|tee -a "$out_dir/$comp_name/User_Searches/Typedurlstime-$comp_name.txt"

      echo "######  "$user_name"  ######" |tee -a "$out_dir/$comp_name/Program_Execution/Run_Open-$comp_name.txt"
      rip.pl -r "$ntuser_path" -p run |grep -va "^$"|tee -a "$out_dir/$comp_name/Program_Execution/Run-$comp_name.txt"

      echo "######  "$user_name"  ######" |tee -a "$out_dir/$comp_name/System_Info/Settings/Compatibility_Flags-$comp_name.txt"
      rip.pl -r "$ntuser_path" -p appcompatflags |grep -va "^$"|tee -a  "$out_dir/$comp_name/System_Info/Settings/Compatibility_Flags-$comp_name.txt"

      echo "######  "$user_name"  ######" |tee -a "$out_dir/$comp_name/Account_Usage/Logons-$comp_name.txt"
      rip.pl -r "$ntuser_path" -p logonstats |grep -va "^$"|tee -a  "$out_dir/$comp_name/Account_Usage/Logons-$comp_name.txt"

      echo "######  "$user_name"  ######" |tee -a "$out_dir/$comp_name/Program_Execution/Jumplist-Reg-$comp_name.txt"
      rip.pl -r "$ntuser_path" -p jumplistdata |grep -va "^$"|tee -a  "$out_dir/$comp_name/Program_Execution/Jumplist-Reg-$comp_name.txt"

      echo "######  "$user_name"  ######" |tee -a "$out_dir/$comp_name/File_Access/Mount-Points-$comp_name.txt"
      rip.pl -r "$ntuser_path" -p mp2 |grep -va "^$"|tee -a  "$out_dir/$comp_name/File_Access/Mount-Points-$comp_name.txt"

      echo "######  "$user_name"  ######" |tee -a "$out_dir/$comp_name/File_Access/Office-cache-$comp_name.txt"
      rip.pl -r "$ntuser_path" -p oisc |grep -va "^$"|tee -a  "$out_dir/$comp_name/File_Access/Office-cache-$comp_name.txt"

      echo "######  "$user_name"  ######" |tee -a "$out_dir/$comp_name/Persistence/Profiler-$comp_name.txt"
      rip.pl -r "$ntuser_path" -p profiler |grep -va "^$"|tee -a "$out_dir/$comp_name/Persistence/Profiler-$comp_name.txt"

      echo "######  "$user_name"  ######" |tee -a "$out_dir/$comp_name/Persistence/Load-$comp_name.txt"
      rip.pl -r "$ntuser_path" -p load |grep -va "^$"|tee -a  "$out_dir/$comp_name/Persistence/Load-$comp_name.txt"

    done
}

#Run RegRipper on SAM Registry hive
function regrip_sam(){
    counter="0" && find $reg_dir -maxdepth 1 -type f 2>/dev/null | grep -i "\/sam$"| while read d;
    do
      echo "Searching for SAM (Regripper)"
      rip.pl -r "$d" -a |tee -a $out_dir/$comp_name/SAM-$comp_name-$counter.txt && counter=$((counter +1));
    done
    find $reg_dir -maxdepth 1 -type f 2>/dev/null | grep -i "\/sam$" | while read d;
    do
      rip.pl -aT -r $d |sed "s/|||/|${comp_name}||/" | grep ".*|.*|.*|.*|.*" | tee -a  $out_dir/$comp_name/Timeline/Regripper-Timeline-$comp_name.TLN
    done
}

#Run RegRipper on AmCache.hve
function regrip_amcache.hve(){
    [ "$amcache_file" ] && \
    echo "Extracting Any RecentFileCache/AmCache (Regripper)"
    rip.pl -aT -r "$amcache_file" |sed "s/|||/|${comp_name}|${user_name}|/"| grep ".*|.*|.*|.*|.*"| tee -a $out_dir/$comp_name/Timeline/Regripper-Timeline-$comp_name.TLN
    rip.pl -r "$amcache_file" -p amcache |tee -a "$out_dir/$comp_name/Amcache-$comp_name.txt"
}

#Run Regripper on SysCache.hve
function regrip_syscache.hve_tln(){
  [ "$syscache_file" ] && \
  rip.pl -aT -r "$syscache_file" | grep ".*|.*|.*|.*|.*" | tee -a  $out_dir/$comp_name/Timeline/Regripper-Timeline-$comp_name.TLN
}

#Consolidating TLN Output and consolidating timelines
function consolidate_timeline(){
    echo "conol tl"
    [ "$out_dir/$comp_name/Timeline/Regripper-Timeline-$comp_name.TLN" ] && echo "Consolidating TLN Files"
###    cat $out_dir/$comp_name/Timeline/Regripper-Timeline-$comp_name.TLN | sort -rn |uniq | tee -a $out_dir/$comp_name/Timeline/Regripper-Timeline-$comp_name.TLN;
    cat $out_dir/$comp_name/Timeline/Regripper-Timeline-$comp_name.TLN |awk -F'|' '{$1=strftime("%Y-%m-%d %H:%M:%S",$1)}{print $1","$2","$3","$4","$5}'|sort -rn | uniq| grep -va ",,,," |tee -a $out_dir/$comp_name/Timeline/Regripper-Timeline-$comp_name.csv.txt
    cat $out_dir/$comp_name/Timeline/Regripper-Timeline-$comp_name.csv.txt|grep -ia ",alert," |tee -a $out_dir/$comp_name/Alert/RegRipperAlerts-$comp_name.csv
    echo "Complete!"
}

function del_no_result(){
  cd $out_dir/$comp_name
  grep -RL ".:." /cases/ |while read d;
  do
    rm $d
  done
}

function usage(){
echo ""
echo "     Usage: $0 <NTFS volume root path or directory containing registry hive(s)> 
          optional: <output directory>  
                    -h  help
                    
                    "
exit
}

#Begin
which rip.pl || usage
[ "$1" == "-h" ] && usage
[ -d "$1" ] || usage
reg_dir=$(find $1/[w,W]*[s,S]\/[s,S]*32\/[c,C]*[g,G] -maxdepth 0 -type d 2>/dev/null)
[ "$reg_dir" == "" ] && reg_dir=$1
find $reg_dir -maxdepth 1 -type f 2>/dev/null |grep -Eiq \/software$\|\/system$\|\/security$\|\/sam$\|\/ntuser.dat$\|\/amcache.hve$\|\syscache.hve$\|\/usrclass.dat$ || usage
ntuser_dirs=$(find $1/[u,U]*[s,S] -maxdepth 0 -type d 2>/dev/null)
amcache_file=$(find $1/[w,W]*[s,S]\/[a,A]*/[P,p]* -maxdepth 1 -type f 2>/dev/null|egrep -m1 -i \/amcache.hve$)
syscache_file=$(find "$1" -maxdepth 0 -type f 2>/dev/null|grep -i -m1 "System\ Volume\ Information\syscache.hve$" )


#set output directory
out_dir=$(readlink -f $2 2>/dev/null)
[ "$out_dir" == "" ] && out_dir=$(pwd)
[ -d "$out_dir" ] || usage

get_computer_name
mkdir -p $out_dir/$comp_name || usage
create_output_dir
create_users_dir
rip_software

rip_security
regrip_ntuser_usrclass
regrip_user_plugins
regrip_sam
regrip_amcache.hve
regrip_syscache.hve_tln
rip_system


#    Clean-up
find $out_dir/$comp_name/Timeline/Regripper-Timeline-$comp_name.TLN -size -2b -delete 2>/dev/null
find $out_dir -empty -delete 2>/dev/null
[ -d "$out_dir/$comp_name" ] && echo "Consolidating Timeline" && consolidate_timeline || usage

[ -d "$out_dir/$comp_name" ] && fdupes -rdN $out_dir/$comp_name 2>/dev/null && echo "Regripper output created in $out_dir/$comp_name" && echo Process Complete!
