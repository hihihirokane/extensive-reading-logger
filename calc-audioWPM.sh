#!/bin/sh


# getduration(): get the duration (seconds) of an audiobook out of iTunes playlists
# arg $1: playlist exported from iTunes "playlist/$1"

function viewpl(){
    awk -Ft '{gsub(//,"\n");print}' "$1"
}

function getduration () {
    # awk -Ft '{gsub(//,"\n");print}' "$1" | awk -Ft '{if(NR>1)sum+=$8}END{printf "%dm%ds\n",int(sum/60),sum%60;}'
    viewpl "$1" | awk -Ft 'NR > 1{sum += $8}END{print sum}'
}

# printf "  WPM\t  1.5x\tSERIES\tTITLE\n" # コラム見出し
# printf " 1x WPM\t   1.5x\tSERIES\tTITLE\n" # コラム見出し
printf " 1x WPM\t   1.5x\t     2x\tSERIES\tTITLE\n" # title of columns
for pls in playlist/* # pls: iTunesから出したプレイリスト
do
    # plsname: シリーズとタイトル(空白,ドット"."あり)
    plsname=`printf "$pls" | cut -f2 -d/ | sed 's/\.txt//'`
    if [ "$plsname" = "note" ]; then continue; fi
    # stage: 本のシリーズとレベル略号
    # title: 正味のタイトル(空白あり)
    # plsname=`printf "$pls" | cut -f2 -d/ | cut -f1 -d.`
    stage=`printf "$plsname" | cut -f1 -d' '`
    title=`printf "$plsname" | sed 's/'"$stage"' //'`
    # words: 本の語数(整数)
    # words=`cat oxford penguin | awk -Ft '$1 ~ /'$stage'/ && $3 ~ /'"$title"'/{sub(/,/, "", $11);print $11}'` # titleの大文字小文字の差を吸収できない
    words=`cat oxford penguin cambridge | grep "$stage" | grep -i "$title" | awk -Ft '{sub(/,/, "", $11);print $11}'` # 任意の出版社のシリーズに対応したい。シリーズ(e.g. CER3, OBW4)からdbを引くには？
    # printf "%d\n" "$words"
    # plsname="$stage $title"
    # printf "%s\n" "$title"
    dur=`getduration "$pls"` # obtaining a Duration of Audio book out of playlist $pls
    # wpm=`./audio-duration.sh "$pls" $words`
    # wpm, wpm2: WPM (整数3桁)
    wpm=`printf "round(%d / %d * 60)\n" $words $dur | cat round.bc - | bc -l`
    wpm15=`printf "round(%d / %d * 60 * 1.5)\n" $words $dur | cat round.bc - | bc -l` # 1.5倍速のwpm
    wpm2=`printf "round(%d / %d * 60 * 2)\n" $words $dur | cat round.bc - | bc -l` # 2倍速のwpm
    # printf "%3d wpm\t%3d wpm\t%s\t%s\n" "$wpm" "$wpm2" "$stage" "$title"
    printf "%7d\t%7d\t%7d\t%s\t%s\n" "$wpm" "$wpm15" "$wpm2" "$stage" "$title"
done
