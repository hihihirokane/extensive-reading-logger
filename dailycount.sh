#!/bin/sh
# 一日あたりの読んだ語数を集計する.
./mktable.awk | tee temp.out | awk -Ft '/[0-9x]{4}\.[0-9x]{2}\.[0-9x]{2}/{print $1}' | uniq | awk -Ft '{d=$1;while((getline < "temp.out") > 0){if($1~d)sum+=$2};close("temp.out");printf "%s\t%8d\t",d,sum;for(i=sum/5000;i>0;i--){printf("* ")};printf("\n");sum=0}'
# while(sum>0){printf("* ");sum-=5000;}
