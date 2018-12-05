# extensive-reading-logger

Making use of
[Graded Reader List](https://sites.google.com/site/erfgrlist/)
provided by ERF (Extensive Reading Foundation) as a list of
tab-separated values (.tsv), **extensive-reading-logger** which consists of AWK scripts make reading records in extensive reading with ```readdone.awk```
and show them as a table with ```mktable.awk```. These AWK scripts allow graded readers as well as ordinary paperbacks to be recorded.

ERFが提供するグレイデッド・リーダーのリスト
[ERF Graded Reader List](https://sites.google.com/site/erfgrlist/)
(.tsv, tab-separated values)
を用いて、多読を記録・表示する
awk
スクリプト。グレイデッド・リーダーでないものは手書きで
```read.done```
を更新する必要があるが、
`mktable.awk`
はその場合も考慮して表示する(予定)。


## Components

1. ```readdone.awk``` 検索と記録。結果は ```read.done``` に書き込まれる。
1. ```mktable.awk``` 多読記録の表示。```read.done``` が必要。

以下はおまけである。

1. ```accum.h``` 累積語数の推移を視覚的に表現する。目盛りは線形と対数から選べる。```read.done``` が必要。
1. ```audio-duration.sh``` iTunesからエクスポートされたプレイリストから、音源の読み上げ時間を測る。
1. ```calc-audioWPM.sh``` iTunesからエクスポートされたプレイリストから、音源の読み上げ速度を計算する。
1. ```dailycount.sh``` 1日単位の語数を表示する。```read.done``` が必要。長くなるので```tail```コマンドと併用するのがよい。
1. ```gosa.awk``` シリーズ語数平均からの各リーダーの散らばりを表示する。

## How to Use

### 検索

第一引数にはグレーデッド・リーダーの出版社名を指定する。Oxford Bookworms Library や Oxford Reading Tree を入力したい場合、第1引数は
```oxford```
または可能な限り省略した
```o``` のみでも指定できる。この
```o[xford]```
の他に指定できる第1引数は、現時点で本邦で入手しやすい
```b[lackcat], ca[mbridge], ce[ngage], m[acmillan], pen[guin], pea[rson]```
である。
候補を絞るには第2引数に検索キーワードを指定する。これは大文字と小文字を区別せず、また拡張正規表現(ERE)の場合には二重引用符が必要である。

```
$ ./readdone.awk o[xford] farrar
OBW5	Brat Farrar	Josephine Tey, Retold by Ralph Mowat	4.5-5.0	24510 	2018.12.06
################################################################################
#### Invoked in the Dry-run mode:                                           ####
#### Put the "--commit" option to append records                            ####
################################################################################
```

<!-- `o[xford], penguin(pearson), cambridge, cengage(heinle),
macmillan, blackcat` のみを用意している。 -->

### 記録
各本の読書時間とページ数を入力する場合には、検索の時点で結果が1件になるまで絞る必要がある。逆に、各本の読書時間とページ数を入力しない場合には、検索の時点で結果が1件になるまで絞る必要はなく、したがって複数のリーダーを一度に登録できる。この場合に第2引数を正規表現を指定できるのは有用である。

```./readdone.awk o[xford] farrar w[hole] [0h]200m[0s] 88 --commit```

### 表示

```./mktable.awk``` (非要約モード) 長くなるので```tail```コマンドと併用するのがよい。

```./mktable.awk w``` (累計語数のみ表示)

```./mktable.awk s OBW5``` (要約モード) 第二引数は正規表現(ERE)の場合、引用符が必要。
