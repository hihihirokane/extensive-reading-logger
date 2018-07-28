#!/bin/sh
# accum.sh: ./accum.sh [-h] days [lin10000|log10]
# arguments: 
# $1: every n days
# $2: lin[0-9]+ or log[0-9]+ or ln
BOLD="\033[1m" #'\e[1;31m'
OFF="\033[m"


function usage(){ echo "Usage: ./accum.sh [-h|-s <lin[class]|log[base]|ln>|-d days] [days] [lin[class]|log[base]|ln]"; exit 1; }

function argcheck_days(){
    case "$1" in # 値の範囲を調べて整数でなければexit 1
	''|*[!0-9]*)
	    echo "Invalid argument for days: use integer"
	    usage
	    ;;
	*)
    	    EVERY=$1
	    ;;
    esac
}

# function argcheck_scale(){
#     case "$1" in # 値の範囲を調べてlin[class]|log[base]|lnでなければexit 1
# 	\(lin|log\)[0-9][0-9]*|ln)
# 	    echo "Invalid argument for days: use integer"
# 	    usage
# 	    ;;
# 	*)
#     	    EVERY=$1
# 	    ;;
#     esac
# }

function init(){
    while getopts "s:d:h" OPTION; do # colon : means the option which requires arguments
    	case "$OPTION" in
    	    h)  # help
		usage
    		;;
    	    s)  # arguments: "log[base]", "ln", "lin[class]", none
		SCALE=$OPTARG
    		;;
    	    d)  # every n day
		# EVERY=$OPTARG
		argcheck_days $OPTARG
    		;;
    	    \?) # unrecognized option - show help
		echo "\\nOption -${BOLD}$OPTARG${OFF} not allowed." > /dev/stderr
		# echo "OPTIND: $OPTIND"
    		usage
    		;;
    	esac
	# echo "OPTIND = $OPTIND"
    done
    shift $((OPTIND-1))

    if [ -z "$SCALE" -a -z "$2" ]; then
    	SCALE="lin50000"
    elif [ "$SCALE" = "lin" -o "$2" = "lin" ]; then
    	SCALE="lin50000"
    elif [ "$SCALE" = "log" -o "$2" = "log" ]; then
    	SCALE="log10"
    elif [ ! -z "$2" ]; then
    	SCALE=$2
    fi
    # else
    # 	argcheck_scale $2

    # if [ ! -z "$2" ]; then
    # 	SCALE=$2
    # elif [ -z "$SCALE" ]; then
    # 	SCALE="lin50000"
    # elif [ "$SCALE" = "lin" ]; then
    # 	SCALE="lin50000"
    # elif [ "$SCALE" = "log" ]; then
    # 	SCALE="log10"
    # else # parse lin[base] or log[base] or ln
    # 	# echo "$SCALE" | awk 
    # 	echo "invalid argument for scale"; exit 1
    # fi

    # if [ $1 = "-h" ]; then
    # 	echo "Usage: ./accum.sh [-h] days [lin[10000]|log10|ln]"
    # 	exit
    # fi

    if [ -z "$EVERY" -a -z "$1" ]; then
    	EVERY=100
    elif [ ! -z "$1" ]; then
	argcheck_days $1
    fi

}

function print_record(){
    printf "%s\t%8d\t" $1 $2
    awk -v DATA=$2 -v SCALE=$3 \
	'
	function print_linear(scale,data){
	    for(i=data/scale-1;i>=0;i--) printf "*"
	}
	function print_log(base,data){
	    for(i=log(data)/log(base)-1;i>=0;i--) printf "*"
	}
	BEGIN{
	    logbase["ln"]=exp(1)
      	    if(SCALE~/lin/){ # linear-scale
                sub(/lin/,"",SCALE)
	        print_linear(SCALE,DATA)
	    }
	    else if(SCALE~/ln/){ # log-scale
   	        print_log(logbase[SCALE], DATA)
	    }
	    else if(SCALE~/log/){ # log-scale
                sub(/log/,"",SCALE)
   	        print_log(SCALE, DATA)
	    }
	    else{
	        printf "no record"
	        exit
	    }
    	# if(SCALE~/log10$/) # log-scale
	#     for(i=log('$2')/log(10)-1;i>0;i--) printf "*"
	# else if(SCALE~/lin10000$/) # linear-scale
	#     for(i='$2'/10000-1;i>0;i--) printf "*"
	# else if(SCALE~/lin25000$/) # linear-scale
	#     for(i='$2'/25000-1;i>0;i--) printf "*"
	# else if(SCALE~/lin50000$/) # linear-scale
	#     for(i='$2'/50000-1;i>0;i--) printf "*"
	# else # if(SCALE~/lin100000$/) # linear-scale
	#     for(i='$2'/100000-1;i>0;i--) printf "*"
	printf"\n"}'
}

function print_scale(){
    awk -v SCALE=$1 \
	'
	function print_scale_linear_old(scale, column, every, tabw){
	    for(i=0;i<column/tabw;i++) if(i % every == 0) printf "%d\t", i * tabw * scale; else printf "\t";
	}
	function print_scale_linear(scale, column, every, tabw){
	    # print scale,column,every,tabw
	    for(i = 0; i < column; ){
	        num = i * scale
		digits = (i == 0) ? 1 : int(log(num)/log(10)) + 1
		nthtab = i / tabw
		if (nthtab == int(nthtab) && nthtab % every == 0){
		    # printf "*i: %d, num: %d, digits: %d, %d, %s*\n", i, num, digits, int(nthtab), (nthtab % every == 0 ? "true" : "false")
		    printf "%d", num
		    i += digits
		}
		else{
		    printf " "
		    i++
		}
	    }
	}
	function print_scale_log(base, column, every, tabw){
	    if(base == logbase["ln"]){
	        for(i=0;i<column/tabw;i++) if(i % every == 0) printf "e^%d\t", i*tabw; else printf "\t";
  	    }else if(base == int(base)){
	        for(i=0;i<column/tabw;i++) if(i % every == 0) printf "%d^%d\t", base, i*tabw; else printf "\t";
  	    }else{
	        for(i=0;i<column/tabw;i++) if(i % every == 0) printf "%.02f^%d\t", base, i*tabw; else printf "\t";
	    }
	}
	BEGIN{
	    logbase["ln"]=exp(1)
	    COLUMN=121; EVERY=3; TABW=8;
	    printf "\t\t\t\t"
	    for(i = 0; i < COLUMN; i++) if(i % (EVERY*TABW) == 0) printf "|"; else printf "-";
	    printf "\n\t\t\t\t"
	    if(SCALE~/lin/){
	        sub(/lin/,"",SCALE)
		# EVERY = int((EVERY * TABW - (log(SCALE)/log(10) + 1)) / TABW) + 1
		# print_scale_linear_old(SCALE, COLUMN, EVERY, TABW)
		print_scale_linear(SCALE, COLUMN, EVERY, TABW)
	    }
	    else if(SCALE~/ln/){
		print_scale_log(logbase[SCALE], COLUMN, EVERY, TABW)
	    }
	    else if(SCALE~/log/){
	        sub(/log/,"",SCALE)
		print_scale_log(SCALE, COLUMN, EVERY, TABW)
	    }
	    else{
		printf "There is no such a scale\n"
	        exit
	    }
	    printf"\n"
	}'
}

init $* # $1 $2
A_DAY=`head -1 read.done | awk -Ft '{print $6}'` # date in integer
ADAY=`date -jf %Y.%m.%d ${A_DAY} +%Y%m%d` # date with a format
echo "BEGIN: $A_DAY"
NEXTDAY=`date -jf %Y%m%d ${ADAY} +%Y%m%d` # next date in integer
# NEXT_DAY=`date -jf %Y%m%d ${NEXTDAY} +%Y.%m.%d`
echo "Every $EVERY Days"
TODAY=`date +%Y.%m.%d`
echo "END: $TODAY"
echo "SCALE: $SCALE"
DAYS=0
WSUM=0
print_scale $SCALE # for debugging
exit # for debugging
./dailycount.sh > .dailycount.tmp
while IFS='' read -r line || [[ -n "$line" ]]; do
    D_RECORD=`echo "$line" | awk -Ft '{print$1}'`
    W=`echo "$line" | awk -Ft '{print$2}'`
    D=`date -jf %Y.%m.%d ${D_RECORD} +%Y%m%d`
    WSUM=$((WSUM+W))
    # printf "%s\t%s\n" "${ADAY}" "${D}"
    # while [ "$ADAY" != "$D" ]; do
    while [ $ADAY -le $D ]; do
	# printf "%s\t%s\n" "${A_DAY}" "${D_RECORD}"
	if [ $ADAY -eq $NEXTDAY ]; then
	    print_record $A_DAY $WSUM $SCALE # $BASE
	    NEXTDAY=`date -jf %Y%m%d -v+${EVERY}d ${ADAY} +%Y%m%d`
	    # NEXT_DAY=`date -jf %Y%m%d ${NEXTDAY} +%Y.%m.%d`
	fi
	DAYS=$((DAY+1))
	# printf "%s\t%s\n" "${A_DAY}" "${D_RECORD}"
	# ADAY=`date -jf %Y.%m.%d -v+${DAYS}d ${ADAY} +%Y.%m.%d`
	ADAY=`date -jf %Y%m%d -v+${DAYS}d ${ADAY} +%Y%m%d`
	A_DAY=`date -jf %Y%m%d ${ADAY} +%Y.%m.%d`
    done
done < "./.dailycount.tmp"
print_scale $SCALE
# print_scale_new $SCALE
