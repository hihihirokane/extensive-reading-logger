#!/opt/local/bin/gawk -F "$" -f lib/round.awk -f lib/getopt.awk -f
#!/usr/bin/awk -F "$" -f

func print_record(){
    rec1 = sprintf("%s\t", $6) #date
    # if($10 == "quit" || $10 == "suspended" || $10 == "res+sus")
    if($10 ~ /(quit|suspended|res\+sus)/)
	rec1 = sprintf(rec1 "%7d\t", 0) #wordcount
    else rec1 = sprintf(rec1 "%7d\t", $5) #wordcount
    rec1 = sprintf(rec1 "%7d\t", wordcount) # overall
    # for(j=4;j>3;j--) printf "%s\t", $j
    sub(/N\/A/,"NA",$1)
    # levelmap="awk '/^" $1 "/{print $2}' level.map"
    # levelmap | getline level
    # close(levelmap)
    # printf "%s\t", $4
    rec1 = sprintf(rec1 "%s\t", cefr[$1])
    sub(/NA/,"N/A",$1)
    # printf "%s\t", $10 # 2x, 1x or N/A
    if($10 ~ /(suspended|resumed|res\+sus)/ && VerboseOpt in Opt)
	rec1 = sprintf(rec1 "%3.0f%%\t", $7 / $9 * 100)
    else if($10 ~ /quit/)
	rec1 = sprintf(rec1 "quit\t")
    else if(!noaudio[$2] && DebugOpt in Opt)
	rec1 = audiospeed[$1][$2] ? sprintf(rec1 "%3.0f WPM\t", audiospeed[$1][$2]) : sprintf(rec1 " ?  WPM\t")
	# rec1 = sprintf(rec1 "quit\t")
    else if(noaudio[$2])
	rec1 = sprintf(rec1 "N/A\t")
    else if($10 ~ /resumed/)
	rec1 = sprintf(rec1 "\t")
    else rec1 = sprintf(rec1 "%s\t", $10) # N/A or (2x, 1.5x, 1x or 0.5x)
    rec1 = sprintf(rec1 "%s\t", wpm)
    if(DebugOpt in Opt){
	rec1 = sprintf(rec1 "%s\t", $12)
	rec1 = sprintf(rec1 "%5d m\t", $13)
    }
    for(j = 1; j < 3; j++)
	rec1 = sprintf(rec1 "%s\t", $j)
    # printf "%s\t", $3
    return rec1 "\n"
}

func print_headerhooter(nr){
    if(nr < 1){
	return "---------------------------------------------------------------------------------------------------------------\n" \
	    "Date\t\tWords\tSum\tCEFR\taudio\tmin/p\twords/m\t"(DebugOpt in Opt ? "Pages\tTime(m)\tTotal(m)\t" : "") "Reader\tTitle\n" \
	    "---------------------------------------------------------------------------------------------------------------\n"
    }
    else
	return "---------------------------------------------------------------------------------------------------------------\n"
}

function print_help(){
    print "Usage: ./mktable.awk [wordcount|help|summary series]\n"\
	"Shows the table about books you have read"
    exit
}

function print_help_summary(){
    print "Usage: ./mktable.awk [-s] s[ummary] "smul"series"rmul \
	"\n\nSummary mode, option -s for saving the screen without fancy formatting"\
	"\nas the command 'tee'."\
	" The placeholder "smul"series"rmul" accepts a string as well as"\
	"\nan extended regular expression (ERE) but with it dobulequoted."
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

function month(d){
    if(1 <= d && d <= 12)
	return mnth[d]
    else
	return "###"
}

function trimdate(d){
    ty = substr(d, 0, 4)
    tm = substr(d, 6, 2)
    if(ty >= thisyear && tm == thismonth)
	_date = substr(d, 9, 2) # substr(d, 6, 2) 
    else if(ty >= thisyear && tm != thismonth)
	_date = month(int(substr(d, 6, 2)))
    if(ty < thisyear)
    # 	_date = substr(d, 6, 5)
    # else
	# _date = sprintf("%5d", ty)
	_date = sprintf("'%d", substr(ty, 3, 2))
# LC_ALL=en_US.utf-8 date | awk '{print$2}'
    return _date
}

function wpmcolor(wpm_s, wpm_f){
    wpm_i = round(wpm_f)
    if(wpm_f > 195)
        wpm_s = skycol wpm_s def
    else if(wpm_f >= 150)
        wpm_s = blucol wpm_s def
    else if(wpm_f < 75)
        wpm_s = redcol wpm_s def
    else if(wpm_f < 100)
        wpm_s = yelcol wpm_s def
    return wpm_s
}

function getopts(){
    while ((_go_c = getopt(ARGC, ARGV, Options)) != -1){
    	# printf("c = <%c>, Optarg = <%s>\n",  _go_c, Optarg)
    	Opt[_go_c] = 1
    }
    # print "Opt[_go_c]", Opt["w"]
    # print "Optind", Optind
    # for (i = Optind; i < ARGC; i++)
    # 	printf("\tARGV[%d] = <%s>\n", i, ARGV[i])
    # argind = Optind
    # exit 1
    return Optind # index in ARGV of first nonoption argument
}

function short_title(origtitle){
    return gensub(/( (((and|-) )?(Other|Short) Stories)|(:? (Love )?Stories [fF]rom [A-Z][a-z]+))/, "", "g", origtitle)
}

function quit_whole(file, nr){
    printf "%s:%d, A quit or suspended try cannot read the w[hole] of the book\n", file, nr  > "/dev/stderr"
}

function estimate_readingtime(){
    sp = ($1 ~ /(OBW|PGR)1/ ? 130 : ($1 ~ /(OBW|PGR)2/ ? 120 : ($1 ~ /(OBW|PGR)3/ ? 110 : ($1 ~ /(N\/A|PGR5)/ ? 60 : 100))))
    e_min = wordcount1 / sp
    if(e_min >= 1000){
	e_min /= 60; unit = "h"
    }
    return
}

BEGIN{
    ### Initialize ###
    FS = "\t" # field separator
    OFS = "\t" # output field separator
    summary_file = ".mktable.summary"
    summary_file_title = ".mktable.title"
    print "cat /dev/null > " summary_file | "sh"; close("sh")
    print "cat /dev/null > " summary_file_title | "sh"; close("sh")
    comm_today = "date +%Y-%m-%d-T%H:%M"
    comm_today | getline today; close(comm_today)
    mnth[1] = "Jan"
    mnth[2] = "Feb"
    mnth[3] = "Mar"
    mnth[4] = "Apr"
    mnth[5] = "May"
    mnth[6] = "Jun"
    mnth[7] = "Jul"
    mnth[8] = "Aug"
    mnth[9] = "Sep"
    mnth[10] = "Oct"
    mnth[11] = "Nov"
    mnth[12] = "Dec"

    ### Settings for fancy printing ###
    # begin to draw underline
    "tput smul" | getline smul; close("tput smul")
    # end to draw underline
    "tput rmul" | getline rmul; close("tput rmul")
    # "\e[38;5;196m" # red color
    redcol = "[38;5;196m" # red color of escape sequence
    yelcol = "[38;5;226m" # yellow color of escape sequence
    skycol = "[38;5;51m" # sky color (cyan 1) of escape sequence
    blucol = "[38;5;27m" # dodge blue 1 color of escape sequence
    def = "[0m"

    ### Parsing command and option ###
    # argind = 1
    WriteOpt = "w"
    VerboseOpt = "v"
    DebugOpt = "d"
    Options = DebugOpt VerboseOpt WriteOpt
    # Options = WriteOpt
    argind = getopts() # index in ARGV of first nonoption argument
    if(WriteOpt in Opt && Opt[WriteOpt] == 1){
	record_file = "record-" today
    }
    if(ARGV[argind] ~ /^h(elp)?/){
	print_help()
    }
    if(ARGV[argind] ~ /w(ordcount)?/)
	printmode = 0 # runnning total of word count used as an output for another shell script
    else if(ARGV[argind] ~ /s(ummary)?/ && argind + 1 in ARGV){
	printmode = 2 # for summary
	input_series = ARGV[argind + 1]
	# print "" > ".mktable.summary"
	_command = "date +%Y"
	_command | getline thisyear; close(_command)
	# thisyear = 2018
	# _command = "LC_ALL=en_US.utf-8 date"
	_command = "date +%m"
	_command | getline thismonth; close(_command)
	# if(3 in ARGV && ARGV[argind + 2] ~ /-s/){
	if(WriteOpt in Opt && Opt[WriteOpt] == 1){
	    record_file = ARGV[argind + 1] "-summary-" today
	}
	# thismonth = gensub(/^(.{3})/,"\\1","",$2)
    }
    else if(ARGV[argind] ~ /s(ummary)?/)
	print_help_summary()
    else if(ARGV[argind] ~ /t(ime)?/)
	printmode = 3 # for summary about time
    else if(argind in ARGV)
    	printmode = 1 # just a table
    else print_help()

    # Prepares a table of reader series and difficulties
    lmap = "./level.map"
    while((getline < lmap) > 0)
	cefr[$1] = $2
    close(lmap)

    # Reading speed in audio: (2x, 1.5x, 1x) or N/A
    noaudiomap = "./no-audio.txt"
    while((getline < noaudiomap) > 0)
	noaudio[short_title($2)] = 1
    close(noaudiomap)
    audio[0]=""
    audio[1]="NA"

    # Audio speed as a reference
    if(DebugOpt in Opt){
	calccomm = "./calc-audioWPM.awk"
	while((calccomm | getline) > 0){
	    if($4 == "TITLE") continue;
	    # print $4 > "/dev/stderr"
	    audiospeed[$5][$6] = $1
	}
	close(calccomm)
    }

    # Reading Record file
    reading_record = "./read.done"

    # Prints a Table
    # if(printmode == 1) print_headerhooter(nr)
    sk = 0;
    for(nr = 0; (getline < reading_record) > 0;){
	if(/^[ \t]*#/){ sk++; continue } # skip comment lines
	if($5 <= 0){ sk++; continue } # skip failed cases
	if($10 ~ /shadow(ing)?/) $5 = 0
	wordcount1 = $5 # words a whole book has (integer)
	min = 0 # initialize
	e_min = 0 # initialize
	pages = 0 # initialize
	wpm = "" # initialize
	unit = "m" # initialize
	isCalculatingWPM = 0 # initialize
	if($9 && $8 ~ /[0-9]+[hms]/ && $7 ~ /(w(hole)?|[0-9]+)/){
	    if($7 ~ /w(hole)?/ && $10 == "quit"){ # A quit try cannot read the w[hole] of the book
		quit_whole(reading_record, nr + sk + 1); continue
	    }else if($7 ~ /w(hole)?/ && $10 == "suspended"){ # A suspendeded try cannot read the w[hole] of the book
		quit_whole(reading_record, nr + sk + 1); continue
	    }else if($7 ~ /w(hole)?/ && $10 == "res+sus"){ # A suspendeded try cannot read the w[hole] of the book
		quit_whole(reading_record, nr + sk + 1); continue
	    }
	    isCalculatingWPM = 1
	    min = conv_to_min($8) # time which it took to read
	    if($7 ~ /w(hole)?/) # pages you turned during a reading session (integer)
		$7 = $9
	    pages = $7
	    # if(DebugOpt in Opt) print pages,min > "/dev/stderr"
	    if($10 ~ /(quit|res\+sus|resumed)/)
		min += time[$1][$2]
	    if($10 ~ /(suspended|res\+sus)/){
		time[$1][$2] = min
		page[$1][$2] = pages
	    }else if($10 ~ /(quit|resumed)/){
		time[$1][$2] = 0
		page[$1][$2] = 0
	    }
	    ReadingSpeedInPage = min / pages

	    if($7){ # when the user read some pages
		wholepages = $9 # overall pages a whole book has
		WordsPerPage = wordcount1 / wholepages
		ReadingSpeedInWord = pages / min * WordsPerPage
		# printf "%s\t%.1f m/p\t%d words/m\n", $0, ReadingSpeedInPage, ReadingSpeedInWord
		# printf "%s\t%.1f m/p\t%d wpm\n", $0, ReadingSpeedInPage, ReadingSpeedInWord
		rsip = sprintf("%.1f m/p\t", ReadingSpeedInPage)
		wpm1 = sprintf("%3.0f", ReadingSpeedInWord)
		if(! (WriteOpt in Opt))
		    wpm1 = wpmcolor(wpm1, ReadingSpeedInWord) # arg: string of wpm, float of wpm
		wpm = rsip wpm1 " wpm"

		if(printmode == 2 && $10 ~ /(^$|resumed)/)
		    wpml = wpm1 "@" trimdate($6) # $6 : date
		else if(printmode == 2 && $10 ~ /^quit$/) # shows a quitted try
		    wpml = wpm1 "!" trimdate($6) # $6 : date
	    }
	    else{ # $7 == 0 # no read page
	    	# printf "%s\t%.1f m/p\n", $0, ReadingSpeedInPage
	    	wpm = sprintf("%.1f m/p\t", ReadingSpeedInPage)
	    }
	}
	else { # $8 !~ /[0-9]+[hms]/ || $7 !~ /(whole|[0-9]+)/ || $9 <= 0
	    wpm = "\t"
	    if(printmode == 2)
		wpml = "n/a@" trimdate($6) # $6 : date
	}
	if(DebugOpt in Opt && $10 !~ /(quit|suspended|res\+sus)/ && (isCalculatingWPM && $7 < $9 || !isCalculatingWPM)){
	    estimate_readingtime()
	    $12 = sprintf("  about\t%5.1f %s", e_min, unit)
	}
	if(DebugOpt in Opt && (isCalculatingWPM && $7 == $9) || $10 ~ /quit/)
	    $12 = sprintf("pp. %3d\t%5.1f %s", pages, min, unit)
	if(DebugOpt in Opt){
	    if(VerboseOpt in Opt && $10 ~ /(suspended|res\+sus)/)
		$12 = "\t"
	    if(unit == "h")
		OverallTimeInMinutes += (e_min ? e_min : min) * 60
	    else
		OverallTimeInMinutes += e_min ? e_min : min
	    $13 = round(OverallTimeInMinutes)
	}

	# if(printmode == 2 && ($10 == "" || $10 == "quit" || $10 == "resumed")){ # only if a book is read in silent (no aloud or no audio)
	if(printmode == 2 && $10 ~ /(^$|quit|resumed)/){ # only if a book is read in silent (no aloud or no audio)
	    # booktitle = gensub(/:? (and |- )?(Other |Short )?([A-Z][a-z]+ )?Stories( from [A-Z][a-z]+)?/, "", "g", $2)  # - Short Stories
	    # booktitle = gensub(/( (((and|-) )?(Other|Short) Stories)|(:? (Love )?Stories [fF]rom [A-Z][a-z]+))/, "", "g", $2)
	    booktitle = short_title($2)
	    len_title = length(booktitle)
	    if(len_title_max < len_title) len_title_max = len_title
	    if(summary[$1][booktitle] == "") summary[$1][booktitle] = (DebugOpt in Opt && noaudio[booktitle] ? "N/A\t" : "") wpml
	    # if(! ($1, booktitle) in summary) summary[$1][booktitle] = (DebugOpt in Opt && noaudio[booktitle] ? "N/A\t" : "") wpml
	    else summary[$1][booktitle] = summary[$1][booktitle] "\t" wpml
	    # summary[$1][booktitle][repcnt[$1, booktitle]] = wpml
	    # repcnt[$1, booktitle]++
	}

	# if(!$8 || $8 ~ /N\/A/){ # skip a line with reading time and pages empty ($8) or "N/A"
	#     # for(j=1;j<5;j++) printf "%s\t", $j
	#     # print_record()
	#     # print #$5
	# }
	nr += 1
	if($10 ~ /(quit|suspended|res\+sus|shadow(ing)?)/)
	    unr++
	else
	    wordcount += wordcount1
	if(printmode == 1){
	    if($10 ~ /(suspended|res\+sus)/){
		if(VerboseOpt in Opt)
		    records = records print_record()
	    }
	    else records = records print_record()
	}
    }
    close(reading_record)

    # Prints the Summary instead of the Table
    if(printmode == 2){
	ns = 0  # the number of series
	for(series1 in summary) # array `se' contains the name of series with regexp in 2nd arg hit
	    if(series1 ~ input_series){
		se[ns++] = series1
	    }
	if(ns <= 0){
	    printf "the argument is out of bound: %s\n", input_series
	    print_help()
	    exit 1
	}

	for(i = 0; i < ns; i++)
        for(title in summary[se[i]]){
	    # outline = sprintf("%s\t%s", input_series, title)
	    # outline = sprintf("%s", title)
	    outline = title
	    len_title = length(title)
	    tabs = int(len_title_max / 8) - int(len_title / 8)
	    for(k = 0; k <= tabs; k++) outline = outline sprintf("\t")
	    outline = outline sprintf("%s", summary[se[i]][title])
	    # ol = summary[se[i]][title][0]
	    # for(j = 1; j < repcnt[se[i], title]; j++)
	    # 	ol = ol "\t" summary[se[i]][title][j]
	    # outline = outline ol
	    print se[i], outline >> summary_file
	    # print input_series, title, summary[input_series][title] >> summary_file
	    # print input_series, title >> summary_file_title
	    # print summary[input_series][title] >> summary_file
	}
	# close(summary_file_title)
	close(summary_file)
	print "sort " summary_file | "sh"; close("sh")
	if(WriteOpt in Opt && Opt[WriteOpt] == 1){
	    print "sort " summary_file " > " record_file | "sh" # escape sequence must be erased.
	    close("sh")
	    # close(record_file)
	}
    }

    # Prints the Footer of the Table
    message = "Cumulative Total: " nr - unr " books, " wordcount " words read" (DebugOpt in Opt ? " in " OverallTimeInMinutes / 60 " hours (" round(wordcount / OverallTimeInMinutes) " wpm)": "")
    if(printmode == 1){
	printf print_headerhooter(0)
	printf records
	printf print_headerhooter(nr)
	print message
	if(WriteOpt in Opt && Opt[WriteOpt] == 1){
	    print print_headerhooter(0) \
		records \
		print_headerhooter(nr) \
		message > record_file
	    close(record_file)
	}
	# print nr " books"
	# print wordcount " words read"
    }
    else if (printmode == 0)
	print wordcount
}

