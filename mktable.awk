#!/opt/local/bin/gawk -F "$" -f
#!/usr/bin/awk -F "$" -f

func print_record(nr){
    printf "%s\t", $6 #date
    printf "%6d\t", $5 #wordcount
    printf "%7d\t", wordcount # overall
    # for(j=4;j>3;j--) printf "%s\t", $j
    sub(/N\/A/,"NA",$1)
    # levelmap="awk '/^" $1 "/{print $2}' level.map"
    # levelmap | getline level
    # close(levelmap)
    # printf "%s\t", $4
    printf "%s\t", cefr[$1]
    sub(/NA/,"N/A",$1)
    # printf "%s\t", $10 # 2x, 1x or N/A
    if(noaudio[$2] && $10 == "") printf "N/A\t"; else printf "%s\t", $10 # N/A or (2x, 1.5x, 1x or 0.5x)
    if(wpmf==1)
	printf "%s\t", wpm
    else printf "\t\t"
    for(j=1;j<3;j++) printf "%s\t", $j
    # printf "%s\t", $3
    printf "\n"
    wpm=""
}

func print_headerhooter(nr){
    if(nr < 1){
	print "---------------------------------------------------------------------------------------------------------------"
	print "Date\t\tWords\tSum\tCEFR\taudio\tmin/p\twords/m\tReader\tTitle"
	print "---------------------------------------------------------------------------------------------------------------"
    }
    else
	print "---------------------------------------------------------------------------------------------------------------"
}

BEGIN{
    FS = "\t"
    OFS = "\t"
    # print ARGV[1]
    # exit
    # printmode=1
    # if(testv == 1){
    # 	print "ざまあ"
    # 	exit
    # }

    # Prepares a table of reader series and difficulties
    lmap="./YL-CEFR.map"
    while((getline < lmap) > 0)
	cefr[$1] = $2
    close(lmap)

    if(ARGV[1] ~ /^h(elp)?/){
    	print "Usage: ./mktable.awk [f|help]\n"\
	    "Shows the table about books you have read"
    	exit
    }
    if(ARGV[1] ~ /f/)
	printmode = 0 # runnning total of word count used as an output for another shell script
    else if(ARGV[1] ~ /summary/){
	printmode = 2 # for summary
	series = ARGV[2]
	# print "" > ".mktable.summary"
	print "cat /dev/null > .mktable.summary" | "sh"
	close("sh")
    } else
	printmode = 1 # just a table
    # reading speed in audio: (2x, 1.5x, 1x) or N/A
    while((getline < "./no-audio.txt") > 0)
	noaudio[$2] = 1
    close("./no-audio.txt")

    # Prints a table
    if(printmode == 1)
	print_headerhooter(nr)
    while((getline < "./read.done") > 0){
	if(/^[ \t]*#/) continue # skip comment lines
	if($8 ~ /[0-9]+[hms]/){
	    min = 0 # minutes you took to turn n pages (integer)
	    sec = 0 # seconds you took to turn n pages (integer)
	    hour = 0 # hours you took to turn n pages (integer)
	    wordcountA = $5 # words a whole book has (integer)
	    if($7 != "" && $9 != ""){
		if($7 ~ /whole/) # pages you turned during a reading session (integer)
		    pages = $9
		else pages = $7
	    }
	    if($8 ~ /[0-9]+s/)
	    	sec = gensub(/([0-9]+h)?([0-9]+)m([0-9]+s)?/, "\\3", 1, $8)
	    if($8 ~ /[0-9]+m/)
		min = gensub(/([0-9]+h)?([0-9]+)m([0-9]+s)?/, "\\2", 1, $8)
	    if($8 ~ /[0-9]+h/)
		hour = gensub(/([0-9]+)h([0-9]+m)?([0-9]+s)?/, "\\1", 1, $8)
	    # print $0,min/$7 " m/p"
	    min += (hour * 60) + (sec / 60)
	    ReadingSpeedInPage = min / pages
	    if($9 != ""){
		wholepages = $9 # overall pages a whole book has
		WordsPerPage = wordcountA / wholepages
		ReadingSpeedInWord = pages / min * WordsPerPage
		# printf "%s\t%.1f m/p\t%d words/m\n", $0, ReadingSpeedInPage, ReadingSpeedInWord
		# printf "%s\t%.1f m/p\t%d wpm\n", $0, ReadingSpeedInPage, ReadingSpeedInWord
		wpm = sprintf("%.1f m/p\t%3.0f wpm", ReadingSpeedInPage, ReadingSpeedInWord)
		if(printmode == 2) wpm = sprintf("%3.0f wpm", ReadingSpeedInWord)
		wpmf = 1
	    }else{
		# printf "%s\t%.1f m/p\n", $0, ReadingSpeedInPage
		wpm = sprintf("%.1f m/p", ReadingSpeedInPage)
		wpmf = 1
	    }
	    if(printmode == 2 && $10 == ""){
		if(summary[$1][$2] == "") summary[$1][$2] = wpm
		else summary[$1][$2] = sprintf("%s\t%s", summary[$1][$2], wpm)
		repeatcount[$1][$2]++
	    }
	}
	# if(!$8 || $8 ~ /N\/A/){ # skip a line with reading time and pages empty ($8) or "N/A"
	#     # for(j=1;j<5;j++) printf "%s\t", $j
	#     # print_record()
	#     # print #$5
	# }
	nr += 1
	wordcount += $5
	if(printmode == 1 && $5 > 0)
	    print_record(nr)
	wpmf = 0
    }
    close("./read.done")
    if(printmode == 2)
	for (title in summary[series]){
	    print series,title,summary[series][title] >> ".mktable.summary"
	}
    close(".mktable.summary")
    print "sort .mktable.summary" | "sh"
    close("sh")
    message = "Cumulative Total: " nr " books, " wordcount " words read"
    if(printmode == 1){
	print_headerhooter(nr)
	print message
	# print nr " books"
	# print wordcount " words read"
    }
    else if (printmode == 0)
	print wordcount
}

# {
#     min=0
#     sum += $5
#     if ($7 && $8){
# 	if($8 ~ /[0-9]+m/){
# 	    min = gensub(/([0-9]+h)?([0-9]+)m/, "\\2", 1, $8)
# 	}
# 	if($8 ~ /[0-9]+h/){
# 	    min += gensub(/([0-9]+)h([0-9]+m)?/, "\\1", 1, $8) * 60
# 	}
# 	print $0,min/$7 " m/p"
#     }
#     else print
# }

# $8 ~ /[0-9]+(h|m)/{
#     pages = $7 # pages you turned while reading
#     min = 0 # minutes you took to turn n pages
#     wordcountA = $5 # words a whole book has
#     if($8 ~ /[0-9]+m/)
# 	min = gensub(/([0-9]+h)?([0-9]+)m/, "\\2", 1, $8)
#     if($8 ~ /[0-9]+h/)
# 	min += gensub(/([0-9]+)h([0-9]+m)?/, "\\1", 1, $8) * 60
#     # print $0,min/$7 " m/p"
#     ReadingSpeedInPage = min / pages
#     if($9 != ""){
# 	wholepages = $9 # pages a whole book has
# 	WordsPerPage = wordcountA / wholepages
# 	ReadingSpeedInWord = pages / min * WordsPerPage
# 	printf "%s\t%.1f m/p\t%d words/m\n", $0, ReadingSpeedInPage, ReadingSpeedInWord
#     }else
# 	printf "%s\t%.1f m/p\n", $0, ReadingSpeedInPage
# }

# $8 !~ /[0-9]+(h|m)/{
# !$8{
#     print #$5
# }

# {
#     # print $5
#     wordcount += $5
# }

# END{
#     # print "----------------------------------------------------------------------------------------------------"
#     # print NR " books, " sum " words read"
#     # print NR " books"
#     # print nr " books"
#     # print wordcount " words read"
# }
