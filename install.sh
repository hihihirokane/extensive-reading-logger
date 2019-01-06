#!/bin/bash
blackcat="Black Cat - Cideb - Black Cat.tsv"
cambridge="Cambridge U. Press - Cambridge U..tsv"
cengage="Cengage_Heinle - Cengage.tsv"
macmillan="Macmillan ELT - Macmillan.tsv"
oxford="Oxford U. Press - Oxford U..tsv"
pearson="Pearson ELT - Penguin.tsv"
penguin="Penguin ELT - Penguin.tsv"

for i in blackcat cambridge cengage macmillan oxford pearson penguin
do ln -s db/"${!i}" $i
echo "$i" >> dblist
done || exit 1
