#!/bin/bash
#analyze4688.sh parses all EventID 4688 and 4689 from the Security.evtx
#
#Function to check and set dependancies
function run_check(){
  [ ! -f "$evtx_file" ] && [ ! -d "$evtx_file" ] && echo "Fail! try again..." && exit
  #Check file if type is an Event Log
  file_type=$(file -b "$evtx_file" 2>/dev/null|grep -o "Event Log")
}
function flatten_2_xml(){
  #First overwrite any files created by previously runs of the script 
  echo "" > /tmp/OUTPUT
  echo "" > 4688.analyzed.Security.evtx.csv
  echo "strict digraph 4688{" > /tmp/Security.evtx.4688.Filtered.dot
  echo "" > /tmp/Flat.txt
  echo "Please wait....."
  echo "Converting to XML and Flattening Security.evtx file(s)"
  #See if evtxexport is installed
  evtxexport_installed=$(type evtxexport 2>/dev/null)
  # Flatten and extract to XML a Single Security event log specified on the command line
  [ -f "$evtx_file" ] && [ "$file_type" == "Event Log" ] && [ "$evtxexport_installed" ] &&  evtxexport -f xml "$evtx_file"|awk '{printf $0}'|sed 's/\s//g'|sed 's/<\/Event>/<\/Event>\n/g'|grep ">468[89]<"|tee -a /tmp/Flat.txt
  #Traverse a directory and Flatten/convert to XML all files ending in "security.evtx" 
  [ -d "$evtx_file" ] && find $evtx_file -type f| grep -i \./security.evtx$ 2>/dev/null | while read line; 
  do
    echo "Found!" $line
    file_type=$(file -b "$line" 2>/dev/null|grep -o "Event Log")
    [ "$evtxexport_installed" ] && [ "$file_type" ] && evtxexport -f xml "$line"|awk '{printf $0}'|sed 's/\s//g'|sed 's/<\/Event>/<\/Event>\n/g'|grep ">468[89]<" |tee -a /tmp/Flat.txt; 
  done
  [ -d "$evtx_file" ] && cat /tmp/Flat.txt|sort|uniq|tee /tmp/Flat1.txt && cp /tmp/Flat1.txt /tmp/Flat.txt
# Command line switch to include only user created processes
[ "$2" == "-U" ] || [ "$2" == "-u" ] && echo "Filtering..." && sed -i '/0x00000000000003e7/d' /tmp/Flat.txt
echo "XML conversion complete!"
}
function extract_results(){
# Event counter for progress indication
counter="0"
Records=$(grep -c . /tmp/Flat.txt)
#Create variables for each field type
cat /tmp/Flat.txt| grep "EventRecordID"| while read -r line; do
process_status=$(echo "$line" |grep -o ">4689<" && echo "Exited" || echo "Created")
record_id=$(echo "$line" |grep -Po '(?<=<EventRecordID>)[0-9]*(?=<\/EventRec)')
timestamp=$(echo "$line" |grep -Po '(?<=SystemTime\=\").{3,35}(?=\"\/)')
pid=$(echo "$line" |grep -Po '(?<="NewProcessId\">)0[xX][0-9a-fA-F]+(?=<\/Data>)' | while read d; do echo $(($d));done)
ppid=$(echo "$line" |grep -Po '(?<="ProcessId\">)0[xX][0-9a-fA-F]+(?=<\/Data>)' | while read d; do echo $(($d));done)
new_process=$(echo "$line" |grep -Po "(?<=NewProcessName\"\>).+?(?=<)")
parent_process=$(echo "$line" |grep -Po "(?<=ParentProcessName\"\>).+?(?=<)")
[ "$parent_process" ] || parentprocess=$(echo "$line" |grep -Po "(?<=\"ProcessName\"\>).+?(?=<)")
[ "$parent_process" == "" ] && parent_process="unknown"
command_line=$(echo "$line" |grep -Po "(?<=CommandLine\"\>).+?(?=<)")
domain=$(echo "$line" |grep -Po '(?<=SubjectDomainName\"\>).+?(?=<)')
user=$(echo "$line" |grep -Po '(?<=SubjectUserName\"\>).+?(?=<)')
sid=$(echo "$line" |grep -Po '(?<=SubjectUserSid\"\>).+?(?=<)')
computer=$(echo "$line" |grep -Po '(?<=Computer\>).+?(?=<)') 
tokenelevation=$(echo "$line" |grep -Po '(?<=TokenElevationType\"\>).+?(?=<)'|sed 's/%//')

# Compensate for different data fields in EID 4689
[ "$process_status" == "Exited" ] && pid=$ppid && ppid="-" && new_process="-" && parent_process="-" && tokenelevation="-"
# Copy fields to html tables
echo "<TR><TD>"$record_id"</TD><TD>"$timestamp"</TD><TD>"$new_process"</TD><TD>"$pid"</TD><TD>"$ppid"</TD><TD>"$parent_process"</TD><TD>"$process_status"</TD><TD>"$command_line"</TD><TD>"$tokenelevation"</TD><TD>"$domain"</TD><TD>"$computer"</TD><TD>"$user"</TD><TD>"$sid"</TD></TR>" >>/tmp/OUTPUT
# Create csv file 
echo $record_id","$timestamp","$new_process","$pid","$ppid","$parent_process","$command_line","$tokenelevation","$domain","$computer","$user","$sid |tee -a Security.evtx.4688.Filtered.csv
# Create directed graph data
graph=$(echo "     \"$new_process\" -> \"$sid\" [label=SID];     \"$new_process\" -> \"$tokenelevation\" [label=RunLevel];     \"$new_process\" -> \"$parent_process\" [label=Parent_Path];")

echo $graph| sed 's/[^0-9a-zA-Z\%\ \=\_\>\:-\[\]-]/\\&/g'| sed 's/;/;\n/'|sed 's/\\/\\\\/g'|tee -a /tmp/Security.evtx.4688.Filtered.dot
counter=$((counter+1))
bunch=$(($counter % 100 ))
[ "$bunch" == 0 ] && echo $counter "of "$Records" Events Processed" 
done
}
function create_html_and_graph(){
echo '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"><html xmlns="http://www.w3.org/1999/xhtml"><head><meta http-equiv="Content-Type" content="text/html; charset=utf-8" /><title>Grabips Output</title>'>/tmp/HTOP
echo '<style>* {margin:0; padding:0; outline:none}body {font:10px Verdana,Arial; margin:25px; background:#fff repeat-x; color:#091f30}.sortable {width:980px; border-left:1px solid #c6d5e1; border-top:1px solid #c6d5e1; border-bottom:none; margin:0 15px}.sortable th {background-color:#999999; text-align:left; color:#cfdce7; border:1px solid #fff; border-right:none}.sortable th h3 {font-size:10px; padding:6px 8px 8px}.sortable td {padding:4px 6px 6px; border-bottom:1px solid #c6d5e1; border-right:1px solid #c6d5e1}.sortable .desc, .sortable .asc {background-color:#666666;}.sortable .head:hover, .sortable .desc:hover, .sortable .asc:hover {color:#fff}.sortable .evenrow td {background:#fff}.sortable .oddrow td {background:#ecf2f6}.sortable td.evenselected {background:#ecf2f6}.sortable td.oddselected {background:#dce6ee}#controls {width:980px; margin:0 auto; height:20px}#perpage {float:left; width:200px}#perpage select {float:left; font-size:11px}#perpage span {float:left; margin:2px 0 0 5px}#navigation {float:left; width:580px; text-align:center}#navigation img {cursor:pointer}#text {float:left; width:200px; text-align:right; margin-top:2px}</style>'>>/tmp/HTOP
echo '<script type="text/javascript"> var TINY={};function T$(i){return document.getElementById(i)}function T$$(e,p){return p.getElementsByTagName(e)}TINY.table=function(){function sorter(n){this.n=n;this.pagesize=10000;this.paginate=0}sorter.prototype.init=function(e,f){var t=ge(e),i=0;this.e=e;this.l=t.r.length;t.a=[];t.h=T$$("thead",T$(e))[0].rows[0];t.w=t.h.cells.length;for(i;i<t.w;i++){var c=t.h.cells[i];if(c.className!="nosort"){c.className=this.head;c.onclick=new Function(this.n+".wk(this.cellIndex)")}}for(i=0;i<this.l;i++){t.a[i]={}}if(f!=null){var a=new Function(this.n+".wk("+f+")");a()}if(this.paginate){this.g=1;this.pages()}};sorter.prototype.wk=function(y){var t=ge(this.e),x=t.h.cells[y],i=0;for(i;i<this.l;i++){t.a[i].o=i;var v=t.r[i].cells[y];t.r[i].style.display="";while(v.hasChildNodes()){v=v.firstChild}t.a[i].v=v.nodeValue?v.nodeValue:""}for(i=0;i<t.w;i++){var c=t.h.cells[i];if(c.className!="nosort"){c.className=this.head}}if(t.p==y){t.a.reverse();x.className=t.d?this.asc:this.desc;t.d=t.d?0:1}else{t.p=y;t.a.sort(cp);t.d=0;x.className=this.asc}var n=document.createElement("tbody");for(i=0;i<this.l;i++){var r=t.r[t.a[i].o].cloneNode(true);n.appendChild(r);r.className=i%2==0?this.even:this.odd;var cells=T$$("td",r);for(var z=0;z<t.w;z++){cells[z].className=y==z?i%2==0?this.evensel:this.oddsel:""}}t.replaceChild(n,t.b);if(this.paginate){this.size(this.pagesize)}};sorter.prototype.page=function(s){var t=ge(this.e),i=0,l=s+parseInt(this.pagesize);if(this.currentid&&this.limitid){T$(this.currentid).innerHTML=this.g}for(i;i<this.l;i++){t.r[i].style.display=i>=s&&i<l?"":"none"}};sorter.prototype.move=function(d,m){var s=d==1?(m?this.d:this.g+1):(m?1:this.g-1);if(s<=this.d&&s>0){this.g=s;this.page((s-1)*this.pagesize)}};sorter.prototype.size=function(s){this.pagesize=s;this.g=1;this.pages();this.page(0);if(this.currentid&&this.limitid){T$(this.limitid).innerHTML=this.d}};sorter.prototype.pages=function(){this.d=Math.ceil(this.l/this.pagesize)};function ge(e){var t=T$(e);t.b=T$$("tbody",t)[0];t.r=t.b.rows;return t};function cp(f,c){var g,h;f=g=f.v.toLowerCase(),c=h=c.v.toLowerCase();var i=parseFloat(f.replace(/(\$|\,)/g,"")),n=parseFloat(c.replace(/(\$|\,)/g,""));if(!isNaN(i)&&!isNaN(n)){g=i,h=n}i=Date.parse(f);n=Date.parse(c);if(!isNaN(i)&&!isNaN(n)){g=i;h=n}return g>h?1:(g<h?-1:0)};return{sorter:sorter}}();</script>'>>/tmp/HTOP
echo '</head><body><table cellpadding="0" cellspacing="0" border="0" id="table" class="sortable"><thead><tr><th><h3>RecordID</h3></th><th><h3>EventTime</h3></th><th><h3>Process_Name</h3></th><th><h3>PID</h3></th><th><h3>ParentPID</h3></th><th><h3>Parent_Name</h3></th><th><h3>Process_Status</h3></th><th><h3>Command_Line</h3></th><th><h3>Token_Elevation</h3></th><th><h3>Domain</h3></th><th><h3>Computer_Name</h3><th><h3>User_Name</h3></th><th><h3>SID</h3></th></tr></thead><tbody>'>>/tmp/HTOP
echo '</tbody></table><script type="text/javascript">  var sorter = new TINY.table.sorter("sorter");sorter.head = "head";sorter.asc = "asc";sorter.desc = "desc";sorter.even = "evenrow";sorter.odd = "oddrow";sorter.evensel = "evenselected";sorter.oddsel = "oddselected";sorter.paginate = true;sorter.currentid = "currentpage";sorter.limitid = "pagelimit";sorter.init("table",1);</script></body></html>' >/tmp/HFOOT
cat /tmp/HTOP /tmp/OUTPUT /tmp/HFOOT > Security.evtx.4688.Filtered.html 
echo "}" >> /tmp/Security.evtx.4688.Filtered.dot
dot -Tpng /tmp/Security.evtx.4688.Filtered.dot -o Security.evtx.4688.Filtered.png
echo ""   
}
#Suspicous processes possibly related to lateral movement
# https://www.jpcert.or.jp/english/pub/sr/20170612ac-ir_research_en.pdf 
alert_processes="psexec.exe\|powershell.exe\|wmic.exe\|cscript.exe\|wscript.exe\|winrshost.exe\|winrs.exe\|at.exe\|taskeng.exe\|dumpsvc.exe\|wce.exe\|mimikatz\|pwdump\|lslsass\|webbrowserpassview.exe\|mstsc.exe\|wmiprvse.exe\|sdbinst.exe\|ntdsutil.exe\|vssadmin.exe\|net.exe\|net1.exe\|icalcs.exe\|wevtutil.exe\|csude.exe\|dsquery.exe\|ldifde.exe\|sdelete.exe\|mailpv.exe\|rdpv.exe"
clear
echo "analyze4688.sh -parses Security.evtx logs for process activity (EID4688,4689) and outputs html, csv and directed graph" 
echo ""
echo "Usage: analyze4688.sh [file or directory...] -U (Only Processes Created by a User) "
echo ""
evtx_file="$1"
run_check
flatten_2_xml
extract_results
create_html_and_graph
alerts=$(cat Security.evtx.4688.Filtered.csv| grep $alert_processes)
[ "$alerts" ] && echo "Suspicous processes possibly related to lateral movement detected" && echo $alerts
echo "Process Complete" 