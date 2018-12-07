#!/usr/bin/awk -F "$" -f

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
    DBN[0,"prefix"] = 2 # [na] or [NA]
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

    # looking for command-line options
    for(i = 1; i < ARGC; ++i){
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
    if(DBNAME ~ /peng?u?i?n?/)
	dbno = 6
    else if(DBNAME ~ /pear?s?o?n?/)
	dbno = 7
    else if(DBNAME ~ /cam?b?r?i?d?g?e?/)
	dbno = 2
    else if(DBNAME ~ /(cen?g?a?g?e?|he?i?n?l?e?)/)
	dbno = 3
    else if(DBNAME ~ /ma?c?m?i?l?l?a?n?/)
	dbno = 4
    else if(DBNAME ~ /ox?f?o?r?d?/)
	dbno = 5
    else if(DBNAME ~ /(bl?a?c?k?c?a?t?)/)
	dbno = 1
    else if(DBNAME ~ /[nN][aA]?/)
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
	if($1~/./){
	    result[resultno]=sprintf("%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s",\
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
    if(system(mkdir) == 0 && system(backup) == 0){
	calc_wordcount | getline wordcount; close(calc_wordcount)
	print wordcount " words read"
	# print backup
    	# print "\"" reading_records "\" doesn't exist";
	# exit
    }
}
