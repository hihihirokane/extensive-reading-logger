#!/bin/sh
./calc-audioWPM.sh | awk -Ft 'BEGIN{print"<table>\n<thead>"}{gsub(/^ +/,"",$1);gsub(/^ +/,"",$2)}NR==1{printf "<tr><th>%s</th><th>%s</th><th>%s</th><th>%s</th></tr>\n</thead>\n<tbody>\n",$1,$2,$4,$5}NR>1{printf "<tr><td>%s</td><td>%s</td><td>%s</td><td>%s</td></tr>\n",$1,$2,$4,$5}END{print"</tbody>\n</table>"}'
