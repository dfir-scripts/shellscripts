curl -s -O http://s3.amazonaws.com/alexa-static/top1m.csv.zip|unzip -q -o top1m.csv.zip
awk -F'.' '{print $NF}' <top1m.csv|sort|uniq -c|sort -rn|awk -F' ' '{print $0,$1/10000"%"}'
