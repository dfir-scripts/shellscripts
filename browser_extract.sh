#!/bin/bash
# Extracts basic Chrome, Brave, Firefox and IE/Edge history 
# usage: $0 <path to mount point or %SystemDrive%> <Output Directory>
#       Example: ./browser_extract.sh /mnt/image_mount/ /cases
#       Example: ./browser_extract.sh /kape/Desktop-1/c /cases/Desktop-1"

#Timeline Chrome/Brave metadata
function chrome2tln(){
  browser_dir=$(find $input_path/Users/*/AppData/Local -type d 2>/dev/null|grep -E "Google/Chrome/User Data/Default$"\|"BraveSoftware/Brave-Browser/User Data/Default$")
  if [ "$browser_dir" != '' ] ; then
    echo "Looking for Chrome and Brave Browser files..."
    echo "${browser_dir}" | \
    while read d;
    do
      browser_type=$(echo "$d" |grep -oE -m1 Chrome\|BraveS |grep -oE Chrome\|Brave)
      user_name=$(echo "$d"|sed 's/\/AppData.*//'|sed 's/^.*\///')
      cd "$d"
      if [ -f "History" ]; then
        #Extract Chrome/Brave Browsing history
        cd "$d"
        echo "Searching for $browser_type History (sqlite3)" 
        sqlite3 "History" "select datetime(last_visit_time/1000000-11644473600, 'unixepoch'),url, title, visit_count from urls ORDER BY last_visit_time" | \
        awk -F'|' '{print $1",,,,[URL]:"$2",TITLE: "$3", VISIT COUNT:"$4}'| \
        sed "s/,,,,/,${browser_type},${comp_name},${user_name},/" >> "$output_dir/$user_name-$browser_type-History.csv"
        echo "Searching for $browser_type Browser Search Strings (sqlite3)"
        [ -f "$output_dir/$user_name-$browser_type-History.csv" ]  && \
        cat "$output_dir/$user_name-$browser_type-History.csv" | grep -aP ".com/search\?q"\["\W"] |\
        awk -v FS="([hH][tT][tT][Pp]|&)" '{print "http"$2}' >> $output_dir/$user_name-$browser_type-Searches.csv
        [ -f "$output_dir/$user_name-$browser_type-History.csv" ]  && \
        cat "$output_dir/$user_name-$browser_type-History.csv" | grep -aP ".com/search\?[^q][^=]"| \
        awk -v FS="([hH][tT][tT][Pp]| )" '{print "http"$2}'>> $output_dir/$user_name-$browser_type-Searches.csv
        # Extract Chrome/Brave Downloads
        echo "Searching for "$browser_type" Downloads (sqlite3)"
        sqlite3 "History" "select datetime(start_time/1000000-11644473600, 'unixepoch'), url, target_path, total_bytes FROM downloads INNER JOIN downloads_url_chains ON downloads_url_chains.id = downloads.id ORDER BY start_time" | \
        awk -F'|' '{print $1",,,,[DOWNLOAD]-"$2",TARGET:-"$3", BYTES TRANSFERRED:-"$4}' | \
        sed "s/,,,,/,${browser_type},${comp_name},${user_name},/" \
        >> "$output_dir/$user_name-$browser_type-Download.csv"
        #Extract Chrome/Brave cookies
        if [ -f "$d/Cookies" ]; then
          echo "Searching for "$browser_type" COOKIES (sqlite3)"
          sqlite3 "Cookies" "select datetime(cookies.creation_utc/1000000-11644473600, 'unixepoch'), cookies.host_key,cookies.path, cookies.name, datetime(cookies.last_access_utc/1000000-11644473600,'unixepoch','utc'), cookies.value FROM cookies"| \
          awk -F'|' '{print $1",,,,[Cookie Created]:"$2" LASTACCESS: "$5" VALUE: "$4}'| \
          sed "s/,,,,/,${browser_type},${comp_name},${user_name},/" \
          >> "$output_dir/$user_name-$browser_type-Cookies.csv"
        fi

        #Extract Chrome/Brave Login Data
        if [ -f "Login Data" ]; then
          echo "Searching for "$BROWSER_TYPE" Login Data (sqlite3)"
          sqlite3 "Login Data" "select datetime(date_created/1000000-11644473600, 'unixepoch'), origin_url,username_value,signon_realm FROM logins"| \
          awk -F'|' '{print $1",,,,[Login Data]:SITE_ORIGIN:"$2" USER_NAME: "$3" SIGNON_REALM "$4}' |\
          sed "s/,,,,/,${browser_type},${comp_name},${user_name},/" \
          >> "$output_dir/$user_name-$browser_type-LoginData.csv"
        fi
          
        #Extract Chrome/Brave Web Data
        if [ -f "Web Data" ]; then       
          echo "Searching for "$browser_type" Web Data (sqlite3)"
          sqlite3 "Web Data" "select datetime(date_last_used, 'unixepoch'), name,value, count, datetime(date_created, 'unixepoch') from autofill" | \
          awk -F'|' '{print $1",,,,[WebData] CREATED:"$5" NAME:"$2" VALUE:"$3" COUNT:"$4}' |\
          sed "s/,,,,/,${browser_type},${comp_name},${user_name},/" >> "$output_dir/$user_name-$browser_type-WebData.csv"
        fi

        #Extract Chrome Bookmarks
        if [ -f "Bookmarks" ] ; then
          echo "Searching for "$browser_type" Bookmarks (sqlite3)"
          cat "Bookmarks" |jq -r '.roots[]|recurse(.children[]?)|select(.type != "folder")|{date_added,name,url}|join("|")'|\
          awk -F'|' '{print int($1/1000000-11644473600)"|"$2"|"$3}'| \
          awk -F'|' '{$1=strftime("%Y-%m-%d %H:%M:%S",$1)}{print $1",,,,[Bookmark Created] NAME:"$2" URL:"$3}' |\
          sed "s/,,,,/,${browser_type},${comp_name},${user_name},/" \
          >> "$output_dir/$user_name-$browser_type-Bookmarks.csv"
        fi
      fi
    done

    # Run Hindsight on Users Directory
    echo "Running Hindsight on $user_dir Directory"
    mkdir -p $output_dir/tmp
    /root/.local/pipx/venvs/pyhindsight/bin/hindsight.py -i "$input_path" -o "$output_dir/Hindsight" -l "$output_dir/hindsight.log" --temp_dir $output_dir/tmp
  fi
}

function firefox2tln(){
  find $input_path/Users/*/AppData/Roaming/Mozilla/Firefox/Profiles/*/ -maxdepth 0 -type d 2>/dev/null |\
  while read d;
  do
    cd $d
    if [  -f "$d/places.sqlite" ]; then
      echo "Extracting Any Firefox Browser Info (sqlite3)"
      user_name=$(echo "$d"|sed 's/\/AppData.*//'|sed 's/^.*\///')
      #Extract FireFox History 
      sqlite3 file:"$d/places.sqlite" "select (moz_historyvisits.visit_date/1000000), moz_places.url, moz_places.title, moz_places.visit_count FROM moz_places,moz_historyvisits where moz_historyvisits.place_id=moz_places.id order by moz_historyvisits.visit_date;" 2>/dev/null |\
      awk -F'|' '{$1=strftime("%Y-%m-%d %H:%M:%S",$1)}{print $1",FireFox,,,[URL]:"$2"  TITLE:"$3" VISIT-COUNT:" $4}'| \
      sed "s/,,,/,${comp_name},${user_name},/" >> $output_dir/$user_name-FireFox-History.csv
      #cat "$output_dir/$user_name-FireFox-History.csv" | \
      #grep -aP ".com/search\?q"\["\W"] | awk -v FS="([hH][tT][tT][Pp]|&)" '{print "http"$2}' >> $output_dir/$user_name-Firefox-Searches.csv
      cat "$output_dir/$user_name-FireFox-History.csv"| \
      grep -aP ".com/search\?[^q][^=]" | awk -v FS="([hH][tT][tT][Pp]| )" '{print "http"$3}' >> $output_dir/$user_name-Firefox-Searches.csv
      # Extract FireFox Downloads
      sqlite3 file:"$d/places.sqlite" "select (startTime/1000000), source,target,currBytes,maxBytes FROM moz_downloads" 2>/dev/null |\
      awk -F'|' '{print $1"|FireFox|||[Download]:"$2"=>"$3" BYTES DOWNLOADED=>"$4" TOTAL BYTES=>"$5}' |\
      sed "s/|||/|${comp_name}|${user_name}|/" \
      >> "$output_dir/$user_name-FireFox-Downloads.csv"
      #Extract FireFox cookies
      [ "$d/cookies.sqlite" ] && \
      sqlite3 file:"$d/cookies.sqlite" "select (creationTime/1000000), host,name,datetime((lastAccessed/1000000),'unixepoch','utc'),datetime((expiry/1000000),'unixepoch','utc') FROM moz_cookies" 2>/dev/null|\
      awk -F'|' '{print $1"|FireFox||| [Cookie Created]: "$2" NAME:"$3" ,LAST ACCESS:"$4", EXPIRY: "$5}'| \
      sed "s/|||/|${comp_name}|${user_name}|/" \
      >> "$output_dir/$user_name-FireFox-Cookies.csv"
    fi
  done
}

function webcachev_dump(){
  web_cachev=$(find $input_path/Users/*/AppData/Local/Microsoft/Windows/WebCache -maxdepth 2 -type f 2>/dev/null|grep -i -m1 "WebcacheV" )
  if [  -f "$web_cachev" ]; then
    echo "Extracting any IE WebcacheV0x.dat files (esedbexport)"
    find "$input_path/Users/" -maxdepth 2 ! -type l|grep -i ntuser.dat$ |\
    while read ntuser_path;
    do
      user_name=$( echo "$ntuser_path"|sed 's/\/$//'|awk -F"/" '{print $(NF-1)}')
      find $input_path/Users/$user_name/AppData/Local/Microsoft/Windows/WebCache -maxdepth 2 -type f -iname "WebcacheV*.dat" 2>/dev/null |\
      while read d;
      do
        /usr/bin/esedbexport -t $output_dir/esedbexport-Webcachev01.dat-$user_name "$d" 2>/dev/null;
      done
      find $output_dir/esedbexport-Webcachev01.dat-$user_name.export -type d 2>/dev/null| \
      while read dir;
      do
        grep -hir Visited: $dir |awk '{ s = ""; for (i = 9; i <= NF; i++) s = s $i " "; print s }'|awk -v last=26 '{NF = last} 1' \
        >> $output_dir/$user_name-grep-esedbexport-Webcachev01.dat.csv
        cat "$output_dir/$user_name-grep-esedbexport-Webcachev01.dat$comp_name.csv" | \
        grep -aP ".com/search\?q"\["\W"] | awk -v FS="([hH][tT][tT][Pp]|&)" '{print "http"$2}' \
        >> $output_dir/$user_name-IE-Edge-Searches.csv
      done
    done
  fi  
}

type sqlite3 &>/dev/null || echo "usage: $0 <path to mount point or %SystemDrive%> <Output Directory>
 Example: ./browser_extract.sh /mnt/image_mount/ /cases
 Example: ./browser_extract.sh /kape/Desktop-1/c /cases/Desktop-1" 
input_path=$1
output_dir=$2
[ "$output_dir" == '' ] && output_dir=$(pwd)
if [ "-d $input_path" ]; then
  chrome2tln
  firefox2tln
  webcachev_dump
fi  


