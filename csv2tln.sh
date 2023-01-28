#!/bin/bash
# Converts comma separated 5 columnar csv files with timestamps to standard TLN Format with epoch time"
# http://windowsir.blogspot.com/2009/02/timeline-analysis-pt-iii.html
# Source timestamps can be formatted as "YYYY-MM-DD HH:MM:SS" or "YYYY-MM-DDTHH:MM:SS.mmmmmm"
# ISO 8601 separators are acceptable
# Milliseconds are ignored and UTC is assumed and timezone is not converted!
[ -f "$1" ] || echo "Usage: csv2tln.sh [CSV File]
CSV Input= ISOFORMAT,SOURCE,COMPUTER,USER,MESSAGE
TLN Outpu= EPOCHTIME|SOURCE|COMPUTER|USER|MESSAGE"
[ -f "$1" ] && cat $1  | while read d;
do
 timestamp=$(echo $d| awk -F',' '{print $1}'| grep -E '^[0-9]{4}-(0[1-9]|1[0-2])-(0[1-9]|[1-2][0-9]|3[0-1]).(2[0-3]|[01][0-9]):[0-5][0-9]:[0-5][0-9]')
 [ "$timestamp" != "" ] && tlntime=$(date -d "$timestamp"  +"%s" 2>/dev/null)
 tlninfo=$(echo $d| awk -F',' '{print "|"$2"|"$3"|"$4"|"$5}')
 [ "$timestamp" != "" ] && echo $tlntime$tlninfo
done
