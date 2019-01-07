#!/bin/bash
blackcat="Black Cat - Cideb - Black Cat.tsv"
cambridge="Cambridge U. Press - Cambridge U..tsv"
cengage="Cengage_Heinle - Cengage.tsv"
macmillan="Macmillan ELT - Macmillan.tsv"
oxford="Oxford U. Press - Oxford U..tsv"
pearson="Pearson ELT - Penguin.tsv"
penguin="Penguin ELT - Penguin.tsv"

DBLIST="dblist"
SERIESDB="series-db.map"

if [ -f "$DBLIST" ]; then
    cat /dev/null > "$DBLIST"
fi

if [ -f "$SERIESDB" ]; then
    cat /dev/null > "$SERIESDB"
fi

for i in blackcat cambridge cengage macmillan oxford pearson penguin
do
   if [ ! -L "$i" ]; then ln -s db/"${!i}" $i; fi
   if [ -L "$i" ]; then echo "$i" >> "$DBLIST"; fi
done || exit 1

# ./series.sh
while read db; do
    awk 'BEGIN{OFS="\t"}NR>3{print$1,"'$db'"}' $db | sort | uniq >> "$SERIESDB"
done < "$DBLIST"

# ./calc-audioWPM.sh > audio-WPM
