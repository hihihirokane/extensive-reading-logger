#!/usr/bin/awk -Ft -f
BEGIN{
    OFS="\t"
    series[0]="OBW3"
    series[1]="OBW4"
    series[2]="OBW5"
    ref["OBW3"] = 10000
    ref["OBW4"] = 15000
    ref["OBW5"] = 24000
    for(i in series){
	command = "grep ^" series[i] " oxford"
	while((command | getline) > 0){
	    sub(/,/,"",$11)
	    if($27 ~ /Y/){
		printf "%s\t%d\t\%3.1f%%\t%s\n",$1,$11,sqrt((ref[series[i]]-$11)^2)/ref[series[i]]*100,$3
		item[series[i]]++
		sum[series[i]]+=$11
	    }
	}
	close(command)
	mean[series[i]] = sum[series[i]] / item[series[i]]
    }
    for(i in series)
	print series[i]"'s mean: " mean[series[i]]
}
