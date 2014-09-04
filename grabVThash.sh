echo "GrabVThash.sh searches Virus Total DB for MD5 values"
echo ""
echo "Usage: grabVThash.sh [file or hash...]" 
echo ""
#[ ! -f "$1" ] &&  echo "Fail! try again..." && exit
#[ $1 == "" ] && echo "Fail! try again..." && exit
[ -f "$1" ] && cat $1| while read line; do curl -s -X POST 'https://www.virustotal.com/vtapi/v2/file/report'--form apikey="---apikey-here--" --form resource="$line" |awk -F'positives\":' '{print "VT Hits" $2}'|awk -F' ' '{print $1$2" "$3$6$7}'|sed 's/["}]//g' && sleep 15; done
[ ! -f "$1" ] curl -s -X POST 'https://www.virustotal.com/vtapi/v2/file/report' --form apikey="---apikey-here---" --form resource="$1" |awk -F'positives\":' '{print "VT Hits" $2}'|awk -F' ' '{print $1$2" "$3$6$7}'|sed 's/["}]//g' && sleep 15 ; done
exit
