# extensive-reading-logger

Making use of
[Graded Reader List](https://sites.google.com/site/erfgrlist/)
provided by ERF (Extensive Reading Foundation) as a list of
tab-separated values (.tsv), **extensive-reading-logger** which consists of AWK scripts make reading records in extensive reading with ```readdone.awk```
and show them as a table with ```mktable.awk```. These scripts allow graded readers as well as ordinary paperbacks to be recorded.

ERFが提供するグレイデッド・リーダーのリスト
[ERF Graded Reader List](https://sites.google.com/site/erfgrlist/)
(.tsv, tab-separated values)
を用いて、多読を記録・表示する
awk
スクリプト。グレイデッド・リーダーでないものは手書きで
```read.done```
を更新する必要があるが、
`mktable.awk`
はその場合も考慮して表示する。


## Components

1. ```readdone.awk``` 検索と記録。結果は ```read.done``` に書き込まれる。
1. ```mktable.awk``` 多読記録の表示。```read.done``` が必要。

以下はおまけである。

1. ```accum.h``` 累計語数の推移を視覚的に表現する。目盛りは線形と対数から選べる。```read.done``` が必要。
1. ```audio-duration.sh``` iTunesからエクスポートされたプレイリストから、音源の読み上げ時間を得る。
1. ```calc-audioWPM.sh``` iTunesからエクスポートされたプレイリストから、音源の読み上げ速度を計算する。
1. ```dailycount.sh``` 1日単位の語数を表示する。```read.done``` が必要。長くなるので```tail```コマンドと併用するのがよい。
1. ```gosa.awk``` シリーズ語数平均からの各リーダーの散らばりを表示する。

## How to Use

### 検索
必要なグレーデッド・リーダーを選ぶためには、
第1引数にグレーデッド・リーダーの出版社名を指定する。Oxford Bookworms Library や Oxford Reading Tree を入力したい場合、第1引数は
```oxford```
または可能な限り省略した
```o``` のみでも指定できる。この
```o[xford]```
の他に指定できる第1引数は、現時点で本邦で入手しやすい
```b[lackcat], ca[mbridge], ce[ngage], m[acmillan], pen[guin], pea[rson]```
である。
候補を絞るには第2引数に検索キーワードを指定する。これは大文字と小文字を区別せず、また拡張正規表現
(ERE)
も指定できるが、その場合には二重引用符が必要である。
```--commit```
オプションがないと記録はしない。

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
```readdone.awk```
コマンドに
```--commit```
オプションをつけることで記録ができる。このオプションの位置は問わない。記録するファイルの既定名は
```read.done```
である。このとき、
```readdone.awk```
コマンドは累計語数を計算して返す。

```
$ ./readdone.awk o[xford] farrar --commit
8647120 words read
```

```--commit```
する際に各リーダーの読書時間と総ページ数を併せて指定すると、後に**表示**する際に読書速度
(WPM)
を計算する。2万語を超えるリーダーについて1冊まるごとの読書時間を測るのは現実的ではないので、数ページを選んでその時間を記入するだけでも計算は可能である。ただし正確さには欠けるだろう。第3引数には「まるごと」の場合
```w```
もしくは
```whole```
を指定し、またはその測ったページ数を指定する。
第4引数の時間表現は、
```10m```
とか
```600s```
といった冗長さを許して指定できる。第5引数は総ページ数である。
* 1冊まるごとの時間を測った場合 ```./readdone.awk o[xford] farrar w[hole] [0h]200m[0s] 88 --commit```
* ある5ページの時間を測った場合 ```./readdone.awk o[xford] farrar 5 [0h]10m[0s] 88 --commit```


各リーダーの読書時間とページ数を**入力する**場合には、検索の時点で結果が1件になるまで絞る必要がある。逆に、各リーダーの読書時間とページ数を**入力しない**場合には、検索の時点で結果が1件になるまで絞る必要はなく、したがって複数のリーダーを一度に登録できる。この場合に第2引数を正規表現を指定できるのは有用である。

### 表示

```./mktable.awk``` (非要約モード) 長くなるので```tail```コマンドと併用するのがよい。

```./mktable.awk w``` (累計語数のみ表示)

```./mktable.awk s OBW5``` (要約モード) 第二引数は正規表現(ERE)の場合、引用符が必要。
