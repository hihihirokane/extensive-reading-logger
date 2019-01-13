#!/opt/local/bin/gawk -F "$" -f lib/round.awk -f lib/getopt.awk -f
#!/usr/bin/awk -F "$" -f

# viewpl: in order to show playlists delete carriage returns (\015)
function viewpl(path){
    # gsub(/#/,"\n") #  # is carriage return, octal is \015
    # while((getline < path) > 0){
    # 	gsub(/\015/,"\n")
    # 	pl = pl $0
    # }
    getline < path; close(path)
    gsub(/\015/,"\n")
    return $0
}

# getduration(): get the duration (seconds) of an audiobook out of iTunes playlists
# arg path: playlist exported from iTunes "playlist/$1"
# arg time: the 2nd argment of `column of time' depends on iTunes versions
function getduration (path, time) {
    # awk -Ft '{gsub(/#/,"\n");print}' "$1" | awk -Ft '{if(NR>1)sum+=$8}END{printf "%dm%ds\n",int(sum/60),sum%60;}'
    # 'NR > 1{sum += $8}END{print sum}'
    dursum = 0
    pl = viewpl(path);
    split(pl, line, /\n/)
    for(i in line){
	if(i == 1) continue
	split(line[i], ar, /\t/)
	if(ar[time])
	    dursum += ar[time]
    }
    return dursum
}

function detectOS(){
    detectos = "echo \"$OSTYPE\""
    detectos | getline ostype; close(detectos)
    return ostype
}

function help(){
    print "except for macOS this isn't supported"; exit 1
}

BEGIN{
    os = detectOS()
    # print os
    if(os ~ /darwin/){
	# iTunesVer1 = "mdls -name kMDItemVersion /Applications/iTunes.app/"
	# iTunesVer1 | getline itunesver; close(iTunesVer1)
	iTunesVer2 = "osascript -e 'tell application \"iTunes\" to set safariVersion to version'"
	iTunesVer2 | getline itunesver; close(iTunesVer2)
	# print itunesver
	split(itunesver, ver, /\./)
	if(ver[1] == 12 && ver[2] == 4)
	    coltime = 8
    }
    else help()
    # path = "playlist/OBW1 Adventures of Tom Sawyer, The.txt"
    # # print viewpl(path)
    # print getduration(path)
    # getline < path
    # gsub(/\015/,"\n")
    # # while((getline < path) > 0){
    # # 	gsub(/\015/,"\n")
    # # 	pl = pl $0
    # # }
    # print; close(path);
    # exit 1
    OFS = "\t"
    SERIESDB = "series-db.map"
    if(system("[ ! -f " SERIESDB " ]") == 0){
	print "There's no files called '" SERIESDB "', kindly execute ./install.sh"
	exit 1
    }
    comm1 = "ls -1 playlist/*"
    print " 1x WPM","  1.25x","   1.5x","     2x","SERIES","TITLE" # Titles of colums
    while((comm1 | getline) > 0){
	if($0 ~ /playlist\/note/) continue;
	path = $0
	sub(/playlist\//,"")
	pls = $0
	sub(/\.txt/, "")
	plsname = $0 # plsname: ERF Code and title, including space ' ' and full stop "."
	split(plsname, arr, / /)
	stage = arr[1] # stage: ERF Code, which consists of series and difficulty (level)
	$0 = plsname
	sub(stage " ", "")
	title = $0 # title: the title of a reader, including space charactes ' '
	# print; continue
	comm2 = "grep " stage " " SERIESDB " | cut -f2 "
	comm2 | getline DB; close(comm2)
	comm3 = "grep \"" stage".*"title "\" " DB " | cut -f11"
	comm3 | getline wordcount; close(comm3) # wordcount: word count per book (integers)
        # words=`cat oxford penguin cambridge | grep "$stage" | grep -i "$title" | awk -Ft '{sub(/,/, "", $11);print $11}'` # 任意の出版社のシリーズに対応したい。シリーズ(e.g. CER3, OBW4)からdbを引くには？
	sub(/,/, "", wordcount)
	duration = getduration(path, coltime) # obtaining a Duration of Audio book out of playlist $pls
	# print stage,wordcount,duration,title; continue
	wpm = round(wordcount / duration * 60)
	wpm12 = round(wordcount / duration * 60 * 1.25) # 1.25 times faster
	wpm15 = round(wordcount / duration * 60 * 1.5) # 1.5 times faster
	wpm2 = round(wordcount / duration * 60 * 2) # twice faster
	printf "%7.0f\t%7.0f\t%7.0f\t%7.0f\t%s\t%s\n", wpm, wpm12, wpm15, wpm2, stage, title
	# printf "%7d\t%7d\t%7.0f\t%7.0f\t%s\t%s\n", wordcount, duration, wpm, wpm15, stage, title
	# wordcount = 0
    }
    close(comm1)
}
