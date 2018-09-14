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
    printf "%s\t", wpm
    for(j = 1; j < 3; j++) printf "%s\t", $j
    # printf "%s\t", $3
    printf "\n"
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

function print_help(){
    print "Usage: ./mktable.awk [f|help|summary series]\n"\
	"Shows the table about books you have read"
    exit
}

function conv_to_min(hms){ # format of the argument: ([0-9]+h)?([0-9]+m)?([0-9]+s)?
    s = 0 # seconds you took to turn n pages (integer)
    m = 0 # minutes you took to turn n pages (integer)
    h = 0 # hours you took to turn n pages (integer)
    if(hms ~ /[0-9]+s/)
	s = gensub(/([0-9]+h)?([0-9]+)m([0-9]+s)?/, "\\3", 1, hms)
    if(hms ~ /[0-9]+m/)
	m = gensub(/([0-9]+h)?([0-9]+)m([0-9]+s)?/, "\\2", 1, hms)
    if(hms ~ /[0-9]+h/)
	h = gensub(/([0-9]+)h([0-9]+m)?([0-9]+s)?/, "\\1", 1, hms)
    # print $0,min/$7 " m/p"
    m += (h * 60) + (s / 60)
    return m
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

    # Initialize
    if(ARGV[1] ~ /^h(elp)?/){
	print_help()
    }
    if(ARGV[1] ~ /f/)
	printmode = 0 # runnning total of word count used as an output for another shell script
    else if(ARGV[1] ~ /summary/ && ARGV[2] != ""){
	printmode = 2 # for summary
	series = ARGV[2]
	# print "" > ".mktable.summary"
    } else if(ARGV[1] == "")
	printmode = 1 # just a table
    else print_help()

    ### Settings for fancy printing ###
    # begin to draw underline
    "tput smul" | getline smul; close("tput smul")
    # end to draw underline
    "tput rmul" | getline rmul; close("tput rmul")
    # "\e[38;5;196m" # red color
    redcol = "[38;5;196m" # red color of escape sequence
    yelcol = "[38;5;226m" # yellow color of escape sequence
    skycol = "[38;5;51m" # sky color of escape sequence
    blucol = "[38;5;27m" # blue color of escape sequence
    def = "[0m"
    summary_file = ".mktable.summary"
    summary_file_title = ".mktable.title"
    print "cat /dev/null > " summary_file | "sh"
    print "cat /dev/null > " summary_file_title | "sh"
    close("sh")

    # Prepares a table of reader series and difficulties
    lmap = "./YL-CEFR.map"
    while((getline < lmap) > 0)
	cefr[$1] = $2
    close(lmap)

    # Reading speed in audio: (2x, 1.5x, 1x) or N/A
    noaudiomap = "./no-audio.txt"
    while((getline < noaudiomap) > 0)
	noaudio[$2] = 1
    close(noaudiomap)

    # Prints a Table
    if(printmode == 1) print_headerhooter(nr)
    while((getline < "./read.done") > 0){
	if(/^[ \t]*#/) continue # skip comment lines
	if($5 <= 0) continue # skip failed cases
	wordcount1 = $5 # words a whole book has (integer)
	if($8 ~ /[0-9]+[hms]/ && $7 ~ /(whole|[0-9]+)/){
	    wpm = "" # initialize
	    min = conv_to_min($8) # time which it took to read
	    # if($9 > 0){
	    if($7 ~ /whole/) # pages you turned during a reading session (integer)
		pages = $9
	    else pages = $7
	    # }
	    ReadingSpeedInPage = min / pages

	    if($9 > 0){ # when there exist read pages
		wholepages = $9 # overall pages a whole book has
		WordsPerPage = wordcount1 / wholepages
		ReadingSpeedInWord = pages / min * WordsPerPage
		# printf "%s\t%.1f m/p\t%d words/m\n", $0, ReadingSpeedInPage, ReadingSpeedInWord
		# printf "%s\t%.1f m/p\t%d wpm\n", $0, ReadingSpeedInPage, ReadingSpeedInWord
		rsip = sprintf("%.1f m/p\t", ReadingSpeedInPage)
		wpm1 = sprintf("%3.0f", ReadingSpeedInWord)
		if(ReadingSpeedInWord >= 200)
		    wpm1 = skycol wpm1 def
		else if(ReadingSpeedInWord >= 150)
		    wpm1 = blucol wpm1 def
		else if(ReadingSpeedInWord < 100)
		    wpm1 = yelcol wpm1 def
		wpm = rsip wpm1 " wpm"

		if(printmode == 2)
		    wpml = wpm1 "@" $6 # $6 : date
	    }
	    else{ # $9 == 0 # no read page
	    	# printf "%s\t%.1f m/p\n", $0, ReadingSpeedInPage
	    	wpm = sprintf("%.1f m/p\t", ReadingSpeedInPage)
	    }
	}
	else { # $8 !~ /[0-9]+[hms]/ || $7 !~ /(whole|[0-9]+)/ || $9 <= 0
	    wpm = "\t"
	    if(printmode == 2)
		wpml = "n/a@" $6 # $6 : date
	}

	if(printmode == 2 && $10 == ""){ # only when book is read in silent (no aloud or no audio)
	    len_title = length($2)
	    if(len_title_max < len_title) len_title_max = len_title
	    if(summary[$1][$2] == "") summary[$1][$2] = wpml
	    else summary[$1][$2] = summary[$1][$2] "\t" wpml
	    repeatcount[$1][$2]++
	}

	# if(!$8 || $8 ~ /N\/A/){ # skip a line with reading time and pages empty ($8) or "N/A"
	#     # for(j=1;j<5;j++) printf "%s\t", $j
	#     # print_record()
	#     # print #$5
	# }
	nr += 1
	wordcount += wordcount1
	if(printmode == 1 && wordcount1 > 0)
	    print_record(nr)
    }
    close("./read.done")

    # Prints the Summary instead of the Table
    if(printmode == 2){
	for(ser in summary)
	if(ser ~ series)
	for(title in summary[ser]){
	    # outline = sprintf("%s\t%s", series, title)
	    outline = sprintf("%s", title)
	    len_title = length(title)
	    tabs = int(len_title_max / 8) - int(len_title / 8)
	    for(k = 0; k <= tabs; k++) outline = outline sprintf("\t");
	    outline = outline sprintf("%s", summary[ser][title])
	    print ser, outline >> summary_file
	    # print series, title, summary[series][title] >> summary_file
	    # print series, title >> summary_file_title
	    # print summary[series][title] >> summary_file
	}
	# close(summary_file_title)
	close(summary_file)
	# print "sort " summary_file | "sh"
	print "sort " summary_file | "sh"
	close("sh")
    }

    # Prints the Footer of the Table
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
#     wordcount1 = $5 # words a whole book has
#     if($8 ~ /[0-9]+m/)
# 	min = gensub(/([0-9]+h)?([0-9]+)m/, "\\2", 1, $8)
#     if($8 ~ /[0-9]+h/)
# 	min += gensub(/([0-9]+)h([0-9]+m)?/, "\\1", 1, $8) * 60
#     # print $0,min/$7 " m/p"
#     ReadingSpeedInPage = min / pages
#     if($9 != ""){
# 	wholepages = $9 # pages a whole book has
# 	WordsPerPage = wordcount1 / wholepages
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
