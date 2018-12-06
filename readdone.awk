#!/usr/bin/awk -F "$" -f

function init(){
    OFS = FS = "\t"
    # name of DBs
    DBN[0,"name"] = "No DB"
    DBN[1,"name"] = "blackcat"
    DBN[2,"name"] = "cambridge"
    DBN[3,"name"] = "cengage"
    DBN[4,"name"] = "macmillan"
    DBN[5,"name"] = "oxford"
    DBN[6,"name"] = "penguin"
    DBN[7,"name"] = "pearson"
    # How many first letters to choose a db uniquely
    # DBN[0,"prefix"] = 1
    DBN[1,"prefix"] = 1
    DBN[2,"prefix"] = 2 #"[ca]mbridge"
    DBN[3,"prefix"] = 2 #"[ce]ngage"
    DBN[4,"prefix"] = 1
    DBN[5,"prefix"] = 1
    DBN[6,"prefix"] = 3 #"[pen]guin"
    DBN[7,"prefix"] = 3 #"[pea]rson"
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
    else if(DBNAME ~ /[nN]\/?[aA]/)
	dbno = 0
    else{
	print "no db"; exit
    }
    DBNAME = DBN[dbno, "name"]
    if(system("[ ! -f ./" DBNAME " ]") == 0){
	# print "hello"
    	print "\"" DBNAME "\" doesn't exist"; exit
    }
    if(ARGC < 3){ # hint for searching when arguments are too short
	dbn = substr(DBNAME, 1, DBN[dbno, "prefix"]) "[" substr(DBNAME, 2) "]"
	# dbn = substr(DBNAME, 1, 1) "[" substr(DBNAME, 2) "]"
	printf usage0
	printf smul dbn rmul " " # print usage for a db instead of enumerating db names
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
    date = "date '+%Y.%m.%d'"
    date | getline date1
    close(date)
    grep = "grep -Ei " keyword " ./" DBNAME
    # grep | getline
    resultno = 0
    # print "hello"
    while((grep | getline) > 0){
	sub(/,/, "", $11)
	if($1~/./){
	    result[resultno]=sprintf("%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s",$1,$3,$4,$10,$11,date1,page,time,overallpages,audio)
	    # print $1,$3,$4,$10,$11,date1,page,time,overallpages
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
    # 	print $1,$3,$4,$10,$11,date1,page,time,overallpages

    # Backup read.done
    date = "date \"+%Y%m%d\""
    date | getline date2
    close(date)
    oldbackup = "read.done"
    newbackup = "read.done." date2
    mktbl = "./mktable.awk wordcount"
    mkdir = "mkdir -p ./backup"
    backup = "cp -i " oldbackup " ./backup/" newbackup
    caution = "################################################################################\n" \
	"#### Invoked in the Dry-run mode:                                           ####\n" \
	"#### Put the \"--commit\" option to append records                            ####\n" \
	"################################################################################"
	# "######## $ " backup "                              ###\n" \
    #don't write in if dry-run
    if(dryrun == 1){
	print caution > "/dev/stderr"
	exit
    }
    
    #write in if not dry-run
    for(i = 0; i < resultno; ++i)
	print result[i] >> oldbackup
    if(system(mkdir) == 0 && system(backup) == 0){
	mktbl | getline wordcount
	print wordcount " words read"
	# print backup
    	# print "\"" oldbackup "\" doesn't exist";
	exit
    }
}
