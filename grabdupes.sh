#!/bin/bash
#grabdupes.sh finds duplicate file names and identical files based on md5 hash value
# ~jsbrown
clear
echo "grabdupes.sh finds duplicate file names and identical files based on md5 hash value"
echo ""
echo "Enter Directory Path to Recursively Process:  "
echo "Enter to process current path" 
read DIRECTORY;
echo ""
echo "Enter output file name" 
read -e -p "or enter to accept the default: " -i "DUPES" OUTPUT
echo "Enter Max file size to compare" 
read -e -p "or enter to accept the default: " -i "100M" MAXSIZE
echo ""
echo "Creating temporary directory list"
sudo find . $DIRECTORY -not -empty -size -$MAXSIZE  -type f -printf "%p,%s\n"|sed -e 's/\(.*\)\//\1\/\,/'|awk -F','  '{print "\""$2"\",\""$1"\","$3}' |tee /tmp/dirlist.txt
echo "Complete!"
echo ""
echo "Locating, calculating and comparing files based on SIZE"
cat /tmp/dirlist.txt|awk -F',' '{print $3}'|sort -rn |uniq -d | while read line; do grep ,$line /tmp/dirlist.txt|awk -F',' '{print $2$1}'|sed 's/""//'|xargs md5sum |sort | uniq -w32 --all-repeated; done |tee /tmp/$OUTPUT-SIZE.csv
echo "Complete!"
echo "Locating, calculating and comparing files based on NAME"
cat /tmp/dirlist.txt|awk -F',' '{print $1}'|sort -rn |uniq -d | while read line; do grep $line, /tmp/dirlist.txt|awk -F',' '{print $2$1}'|sed 's/""//'|xargs md5sum; done |tee -a /tmp/$OUTPUT-NAME.csv
echo "Sorting...."
cat /tmp/$OUTPUT-SIZE.csv|sort -rn |uniq|sed -e 's/^.\{34\}/&,/'|sed -e 's/\(.*\)\//\1\/\,/'| awk -F',' '{print $3","$1","$2$3}'|tee $OUTPUT-SIZE.csv
cat /tmp/$OUTPUT-NAME.csv|sort -rn |uniq|sed -e 's/^.\{34\}/&,/'|sed -e 's/\(.*\)\//\1\/\,/'| awk -F',' '{print $3","$1","$2$3}'|tee $OUTPUT-NAME.csv
clear
echo "Process complete....."
echo "The files $OUTPUT-SIZE.csv and $OUTPUT-NAME.csv have been created!"
echo ""
read -p "Would you like the results in HTML (Y/N)?"
         [ "$(echo $REPLY | tr [:upper:] [:lower:])" == "y" ] || exit
cat $OUTPUT-SIZE.csv | awk -F',' '{print "<tr><td>"$1"</td><td>"$2"</td><td>"$3"</td></tr>"}' > /tmp/$OUTPUT-SIZE.csv.html
cat $OUTPUT-NAME.csv | awk -F',' '{print "<tr><td>"$1"</td><td>"$2"</td><td>"$3"</td></tr>"}' > /tmp/$OUTPUT-NAME.csv.html
echo "The files $OUTPUT-SIZE.html and $OUTPUT-NAME.html have been created!"

echo '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"><html xmlns="http://www.w3.org/1999/xhtml"><head><meta http-equiv="Content-Type" content="text/html; charset=utf-8" /><title>Grabdupes Output</title>'> /tmp/HTOP
echo '<style>* {margin:0; padding:0; outline:none}body {font:10px Verdana,Arial; margin:25px; background:#fff repeat-x; color:#091f30}.sortable {width:980px; border-left:1px solid #c6d5e1; border-top:1px solid #c6d5e1; border-bottom:none; margin:0 15px}.sortable th {background-color:#999999; text-align:left; color:#cfdce7; border:1px solid #fff; border-right:none}.sortable th h3 {font-size:10px; padding:6px 8px 8px}.sortable td {padding:4px 6px 6px; border-bottom:1px solid #c6d5e1; border-right:1px solid #c6d5e1}.sortable .desc, .sortable .asc {background-color:#666666;}.sortable .head:hover, .sortable .desc:hover, .sortable .asc:hover {color:#fff}.sortable .evenrow td {background:#fff}.sortable .oddrow td {background:#ecf2f6}.sortable td.evenselected {background:#ecf2f6}.sortable td.oddselected {background:#dce6ee}#controls {width:980px; margin:0 auto; height:20px}#perpage {float:left; width:200px}#perpage select {float:left; font-size:11px}#perpage span {float:left; margin:2px 0 0 5px}#navigation {float:left; width:580px; text-align:center}#navigation img {cursor:pointer}#text {float:left; width:200px; text-align:right; margin-top:2px}</style>'>> /tmp/HTOP
echo '<script type="text/javascript"> var TINY={};function T$(i){return document.getElementById(i)}function T$$(e,p){return p.getElementsByTagName(e)}TINY.table=function(){function sorter(n){this.n=n;this.pagesize=10000;this.paginate=0}sorter.prototype.init=function(e,f){var t=ge(e),i=0;this.e=e;this.l=t.r.length;t.a=[];t.h=T$$("thead",T$(e))[0].rows[0];t.w=t.h.cells.length;for(i;i<t.w;i++){var c=t.h.cells[i];if(c.className!="nosort"){c.className=this.head;c.onclick=new Function(this.n+".wk(this.cellIndex)")}}for(i=0;i<this.l;i++){t.a[i]={}}if(f!=null){var a=new Function(this.n+".wk("+f+")");a()}if(this.paginate){this.g=1;this.pages()}};sorter.prototype.wk=function(y){var t=ge(this.e),x=t.h.cells[y],i=0;for(i;i<this.l;i++){t.a[i].o=i;var v=t.r[i].cells[y];t.r[i].style.display="";while(v.hasChildNodes()){v=v.firstChild}t.a[i].v=v.nodeValue?v.nodeValue:""}for(i=0;i<t.w;i++){var c=t.h.cells[i];if(c.className!="nosort"){c.className=this.head}}if(t.p==y){t.a.reverse();x.className=t.d?this.asc:this.desc;t.d=t.d?0:1}else{t.p=y;t.a.sort(cp);t.d=0;x.className=this.asc}var n=document.createElement("tbody");for(i=0;i<this.l;i++){var r=t.r[t.a[i].o].cloneNode(true);n.appendChild(r);r.className=i%2==0?this.even:this.odd;var cells=T$$("td",r);for(var z=0;z<t.w;z++){cells[z].className=y==z?i%2==0?this.evensel:this.oddsel:""}}t.replaceChild(n,t.b);if(this.paginate){this.size(this.pagesize)}};sorter.prototype.page=function(s){var t=ge(this.e),i=0,l=s+parseInt(this.pagesize);if(this.currentid&&this.limitid){T$(this.currentid).innerHTML=this.g}for(i;i<this.l;i++){t.r[i].style.display=i>=s&&i<l?"":"none"}};sorter.prototype.move=function(d,m){var s=d==1?(m?this.d:this.g+1):(m?1:this.g-1);if(s<=this.d&&s>0){this.g=s;this.page((s-1)*this.pagesize)}};sorter.prototype.size=function(s){this.pagesize=s;this.g=1;this.pages();this.page(0);if(this.currentid&&this.limitid){T$(this.limitid).innerHTML=this.d}};sorter.prototype.pages=function(){this.d=Math.ceil(this.l/this.pagesize)};function ge(e){var t=T$(e);t.b=T$$("tbody",t)[0];t.r=t.b.rows;return t};function cp(f,c){var g,h;f=g=f.v.toLowerCase(),c=h=c.v.toLowerCase();var i=parseFloat(f.replace(/(\$|\,)/g,"")),n=parseFloat(c.replace(/(\$|\,)/g,""));if(!isNaN(i)&&!isNaN(n)){g=i,h=n}i=Date.parse(f);n=Date.parse(c);if(!isNaN(i)&&!isNaN(n)){g=i;h=n}return g>h?1:(g<h?-1:0)};return{sorter:sorter}}();</script>'>> /tmp/HTOP
echo '</head><body><table cellpadding="0" cellspacing="0" border="0" id="table" class="sortable"><thead><tr><th><h3>Name</h3></th><th><h3>MD5 Hash</h3></th><th><h3>Path</h3></th></tr></thead><tbody>'>> /tmp/HTOP
echo '</tbody></table><script type="text/javascript">  var sorter = new TINY.table.sorter("sorter");sorter.head = "head";sorter.asc = "asc";sorter.desc = "desc";sorter.even = "evenrow";sorter.odd = "oddrow";sorter.evensel = "evenselected";sorter.oddsel = "oddselected";sorter.paginate = true;sorter.currentid = "currentpage";sorter.limitid = "pagelimit";sorter.init("table",1);</script></body></html>' > /tmp/HFOOT
cat /tmp/HTOP /tmp/$OUTPUT-SIZE.csv.html /tmp/HFOOT > $OUTPUT-SIZE.html
cat /tmp/HTOP /tmp/$OUTPUT-NAME.csv.html /tmp/HFOOT > $OUTPUT-NAME.html
