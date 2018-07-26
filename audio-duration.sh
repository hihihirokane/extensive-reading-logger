#!/bin/sh
# CDの朗読時間と語数からWPMを測る
# $1: iTunesから出力したプレイリスト "プレイリスト名.txt"
# $2: 本の語数(整数)

# プレーンテキストのプレイリストからCDの長さ(秒: 整数)を測る
function getduration () {
    # awk -Ft '{gsub(//,"\n");print}' "$1" | awk -Ft '{if(NR>1)sum+=$8}END{printf "%dm%ds\n",int(sum/60),sum%60;}'
    awk -Ft '{gsub(//,"\n");print}' "$1" | awk -Ft '{if(NR > 1) sum += $8}END{printf "%d\n",sum;}'
}

wordcount=$2

dur=`getduration "$1"` # obtaining a Duration of Audio book from playlist
# calc WPM from Word count $2
# echo $wordcount $dur
# echo "round($wordcount / $dur * 60)" | cat round.bc - | bc -l
printf "round(%d / %d * 60)\n" $wordcount $dur | cat round.bc - | bc -l
# cat round.bc | bc -l
