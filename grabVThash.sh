#!/bin/bash
echo "GrabVThash.sh searches Virus Total DB for MD5 values"
# jsbrown, CCajigas
echo ""
echo "Usage: grabVThash.sh [file or hash...]" 
echo ""
#process file
[ -f "$1" ] && echo "Processing..." && cat $1|cut -c -32| while read line; do curl -s -X POST 'https://www.virustotal.com/vtapi/v2/file/report' --form apikey="3bf37eadf26be32028c01eb5d2e1907c35589912c64755d2ef16aaaa3ea232ea" --form resource="$line" |awk -F'positives\":' '{print "VT Hits:" $2}'|awk -F' ' '{print $1$2" "$3$6$7}'|sed 's/["}]//g' && sleep 15 ; done && exit
#process single hash
HTEST=$(echo $1|grep -e "[0-9a-f]\{32\}")
[ ! -f "$1" ] && [ "$HTEST" != $1 ] && echo "$1 is not a valid md5 hash"
[ ! -f "$1" ] && [ "$HTEST" == $1 ] && echo "Processing..."  && curl -s -X POST 'https://www.virustotal.com/vtapi/v2/file/report' --form apikey="3bf37eadf26be32028c01eb5d2e1907c35589912c64755d2ef16aaaa3ea232ea" --form resource="$1" |awk -F'positives\":' '{print "VT Hits:" $2}'|awk -F' ' '{print $1$2" "$3$6$7}'|sed 's/["}]//g' && exit
