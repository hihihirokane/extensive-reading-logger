#!/usr/bin/env gawk -F "$" -f lib/round.awk -f lib/getopt.awk -f
#!/usr/bin/awk -F "$" -f

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

function init(){
    OFS = FS = "\t"
    # default filename of reading records
    reading_records = "read.done"
    # name of DBs
    DBN[0,"name"] = "N/A"
    DBN[1,"name"] = "blackcat"
    DBN[2,"name"] = "cambridge"
    DBN[3,"name"] = "cengage"
    DBN[4,"name"] = "macmillan"
    DBN[5,"name"] = "oxford"
    DBN[6,"name"] = "penguin"
    DBN[7,"name"] = "pearson"
    # How many first letters to choose a db uniquely
    DBN[0,"prefix"] = 3 # [n/a] or [N/A], though [na] and [NA] have to be OK
    DBN[1,"prefix"] = 1
    DBN[2,"prefix"] = 2 # [ca]mbridge
    DBN[3,"prefix"] = 2 # [ce]ngage
    DBN[4,"prefix"] = 1
    DBN[5,"prefix"] = 1
    DBN[6,"prefix"] = 3 # [pen]guin
    DBN[7,"prefix"] = 3 # [pea]rson
    dryrun = 1 # (default) don't write in a file
    argdryrun = -1 # (default) write in a file
    # the command-line option "--commit" is defined here, and so it has to come after the 1st argument
    "tput bold" | getline bold; close("tput bold") # begin to get letters bold
    "tput sgr0" | getline sgr0; close("tput sgr0") # end to get letters bold
    "tput smul" | getline smul; close("tput smul") # begin to draw underline
    "tput rmul" | getline rmul; close("tput rmul") # end to draw underline
    usage0 = "Usage: " bold "./readdone.awk" sgr0 " "
    usage1 = smul "b[lackcat]|ca[mbridge]|ce[ngage]|m[acmillan]|o[xford]|pen[guin]|pea[rson]" rmul " "
    usage2 = "[--commit] " smul "keyword" rmul " [[" smul "pages" rmul "] ["\
	smul "time" rmul "] ["\
	smul "overall pages" rmul "]]\n"
    usage3 = "Looks for the record and word count of a graded reader you have just read, manually.\n"

    if(ARGC < 2 || ARGV[1] ~ /^h(elp)?/){ # warning when no arguments are passed
	# print "at least 2 arguments needed"
	printf usage0
	printf usage1
	printf usage2
	printf usage3
	# system("printf \"\e[4m%s\e[0m\" penguin\|oxford")
	exit
    }

    ### Parsing command and option, using an external function getopt() ###
    # argind = 1
    # DebugOpt = "d"
    QuitOpt = "q"
    ContinuationOpt = "c"
    Options = QuitOpt ContinuationOpt
    argind = getopts() # index in ARGV of first nonoption argument

    # looking for command-line options by myself
    for(i = argind; i < ARGC; ++i){
	# if(ARGV[i] ~ /-{1,2}dry(-run)?/){ # not dry-run
	#     # print "## inside dry-run"
	#     dryrun=1 # a flag for dry-run
	#     argdryrun=i # for shifting arguments after the argument "--dry-run"
	# }
	if(ARGV[i] ~ /-{1,2}commit/){ # when appends records to a file
	    dryrun=0 # a flag for commit (not dry-run)
	    argdryrun=i # for shifting arguments after the argument "--commit"
	}
    }
    # no shifting arguments when there's no command-line option after the 1st argument
    if(argdryrun < 0)
	return
    # shifting arguments when the "--dry-run" option is designated or when the "--commit" is not designated
    if(argdryrun == ARGC - 1){ # when the command-line option is in the tail
	ARGV[argdryrun] = ""
    } else  # when the command-line option is except in the tail
	for(i = argdryrun; i < ARGC; ++i){
	    ARGV[i] = ARGV[i+1]
	}
    ARGC--
}

BEGIN{
    init()
    resultno = 0 # the number of records to append
    date = "date '+%Y.%m.%d'"
    date | getline today
    close(date)

    DBNAME = ARGV[1]
    if(DBNAME ~ /^pen(g(u(in?)?)?)?$/)
	dbno = 6
    else if(DBNAME ~ /^pea(r(s(on?)?)?)?$/)
	dbno = 7
    else if(DBNAME ~ /^ca(m(b(r(i(d(ge?)?)?)?)?)?)?$/)
	dbno = 2
    else if(DBNAME ~ /^(ce(n(g(a(ge?)?)?)?)?|h(e(i(n(le?)?)?)?)?)$/)
	dbno = 3
    else if(DBNAME ~ /^m(a(c(m(i(l(l(an?)?)?)?)?)?)?)?$/)
	dbno = 4
    else if(DBNAME ~ /^o(x(f(o(rd?)?)?)?)?$/) #/ox?f?o?r?d?/ -> /(o|ox|oxf|oxfo|oxfor|oxford)/
	dbno = 5
    else if(DBNAME ~ /^b(l(a(c(k(c(at?)?)?)?)?)?)?$/)
	dbno = 1
    else if(DBNAME ~ /^[nN](\/)?[aA]?$/)
	dbno = 0
    else{
	print "no db"; exit
    }
    if(dbno) # graded readers
	DBNAME = DBN[dbno, "name"]
    else{ # at most a non-graded reader can be input from the command line
	if(4 in ARGV){
	    booktitle = ARGV[2]
	    author = ARGV[3]
	    wordcount = ARGV[4]
	}
	if(5 in ARGV){
	    page = ARGV[5]
	    time = ARGV[6]
	    overallpages = ARGV[7]
	    audio = ARGV[8]
	}
	result[resultno] = sprintf("%s\t%s\t%s\tN/A\t%s\t%s\t%s\t%s\t%s\t%s",\
				   DBN[dbno, "name"],booktitle,author,wordcount,\
				   today,page,time,overallpages,audio)
	if(4 in ARGV && dryrun == 1)
	    print result[resultno]
	resultno = 1
    }
    if(dbno && system("[ ! -f ./" DBNAME " ]") == 0){
    	print "\"" DBNAME "\" doesn't exist"; exit
    }
    if(ARGC < 3){ # hint for searching when arguments are too short
	dbn = substr(DBNAME, 1, DBN[dbno, "prefix"])
	dbn2 = dbno ? "[" substr(DBNAME, DBN[dbno, "prefix"]+1) "]" : ""
	# dbn = substr(DBNAME, 1, 1) "[" substr(DBNAME, 2) "]"
	printf usage0
	printf smul dbn dbn2 rmul " " # print usage for a db instead of enumerating db names
	printf usage2
	exit
    }
    
    keyword = ARGV[2]
    page = ARGV[3]
    time = ARGV[4]
    overallpages = ARGV[5]
    audio = ARGV[6]
    # if(ContinuationOpt in Opt)
    # audio = (ResumeOpt in Opt) ? "resumed" :;
	
    # if(ARGC < 5){
    # 	print "aho"
    # 	system("read x")
    # }

    # if((getline < "./"DBNAME) > 0)
    # print "grep -i" keyword " ./" DBNAME | "sh"
    grep = "grep -Ei " keyword " ./" DBNAME
    # grep | getline
    # print "hello"
    while(dbno && (grep | getline) > 0){
	sub(/,/, "", $11)
	if($1 ~ /./){
	    result[resultno] = sprintf("%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s",\
	    			     $1,$3,$4,$10,$11,today,page,time,overallpages,audio)
	    # print $1,$3,$4,$10,$11,today,page,time,overallpages
	    if(dryrun == 1)
		print result[resultno]
	    resultno++
	}
    }
    close(grep)
    # exit
    # # while((getline < "./"DBNAME) > 0)
    # # 	if($0~keyword) break;
    # sub(/,/, "", $11)
    # if($1~/./)
    # 	print $1,$3,$4,$10,$11,today,page,time,overallpages

    # Backup read.done
    # date = "date \"+%Y%m%d\""
    # date | getline date2
    # close(date)
    caution_for_commit =\
	"################################################################################\n" \
	"#### Invoked in the Dry-run mode:                                           ####\n" \
	"#### Put the `--commit' option to append records                            ####\n" \
	"################################################################################"
	# "######## $ " backup "                              ###\n" \
    #don't write in if dry-run
    if(dryrun == 1){
	print caution_for_commit > "/dev/stderr"
	exit
    }
    
    # write in and backup if not dry-run
    backup_records = "read.done." today
    calc_wordcount = "./mktable.awk wordcount"
    mkdir = "mkdir -p ./backup"
    backup = "cp -i " reading_records " ./backup/" backup_records
    for(i = 0; i < resultno; ++i)
	print result[i] >> reading_records
    close(reading_records)
    if(system(mkdir) == 0 && system(backup) == 0 && (6 in ARGV) && ARGV[6] !~ /(quit|suspended|res\+sus)/){
	calc_wordcount | getline wordcount; close(calc_wordcount)
	printf("%'d words read\n", wordcount)
	# print backup
    	# print "\"" reading_records "\" doesn't exist";
	# exit
    }
}
