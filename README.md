# extensive-reading-logger

Making use of
[Graded Reader List](https://sites.google.com/site/erfgrlist/)
provided by ERF (Extensive Reading Foundation) as a list of
tab-separated values (.tsv), **extensive-reading-logger** which consists of AWK scripts make reading records in extensive reading with ```readdone.awk```
and show them as a table with ```mktable.awk```. These scripts allow graded readers as well as ordinary paperbacks to be recorded.

**extensive-reading-logger**
は、ERFが提供するグレイデッド・リーダーのリスト
[ERF Graded Reader List](https://sites.google.com/site/erfgrlist/)
(.tsv, tab-separated values)
を用いて、多読を記録
(```readdone.awk```)
・表示
(```mktable.awk```)
する
AWK
スクリプト群である。リストの検索・記録・表示に用いるスクリプト内部の実質的なUN*Xコマンドは
```grep, cat```
でしかないが、提供されているリストが項目多数であるといった問題を解決する。グレイデッド・リーダーでない読書の記録にも対応するが、その場合の語数については
[Reading Length](https://readinglength.com/)
などから探すか、または
[SSS式算出法](https://www.seg.co.jp/sss/word_count/how-to-count.html)
を用いて手動で算出するなどの必要がある。ただしその場合もエディタ等の手書きで記録を更新する必要はない。

## Installation
インストールするためには、サイト
[ERF Graded Reader List](https://sites.google.com/site/erfgrlist/)
からスクリプト
```readdone.awk```
で指定できる出版社・ブランド
```blackcat, cambridge, cengage, macmillan, oxford, penguin, pearson```
に対応した
.tsv
ファイルをダウンロードしてディレクトリ
```db/```
に置き、アプリケーションルートディレクトリからそれら
.tsv
ファイルへのシンボリックリンクを、名は上記のようにして張る。

## Components

1. ```readdone.awk``` 検索と記録。結果は ```read.done``` に書き込まれる。
1. ```mktable.awk``` 多読記録の表示。```read.done``` が必要。

以下はおまけである。

1. ```accum.h``` 累計語数の推移を視覚的に表現する。目盛りは線形と対数から選べる。```read.done``` が必要。
1. ```calc-audioWPM.sh``` iTunesからエクスポートされたプレイリストから、音源の読み上げ速度を計算する。
1. ```dailycount.sh``` 1日単位の語数を表示する。```read.done``` が必要。長くなるためUN*Xコマンド```tail```と併用するとよい。
1. ```gosa.awk``` シリーズ語数平均からの各リーダーの散らばりを表示する。

## How to Use

### 検索
検索するためのコマンドは
```readdone.awk```
である。
記録に必要なグレーデッド・リーダーを選ぶためには、
* 第1引数にグレーデッド・リーダーの出版社名・ブランド名、
* 候補を絞るために第2引数に検索キーワード、
を指定する。

例えば、
Oxford Bookworms Library
や
Oxford Reading Tree
などを出版するオックスフォード大学出版局のグレーデッド・リーダーを指定したい場合、第1引数は
```oxford```
とする。または可能な限り省略して
```o``` ともできる。<!-- この -->
<!-- ```o[xford]``` -->
<!-- の他に第1引数で指定できる出版社・ブランドは、現時点で本邦で入手しやすい -->
<!-- ```b[lackcat], ca[mbridge], ce[ngage], m[acmillan], pen[guin], pea[rson]``` -->
<!-- である。 -->

例えば、
Brat Farrar, Oxford Bookworms Library Stage 5
を指定したい場合、第2引数は大文字と小文字を区別せず、また拡張正規表現
(ERE)
も指定できるが、その場合には(二重)引用符が必要である。この例では単に
```farrar```
と指定する。

```
$ ./readdone.awk o[xford] farrar
OBW5	Brat Farrar	Josephine Tey, Retold by Ralph Mowat	4.5-5.0	24510 	2018.12.06
################################################################################
#### Invoked in the Dry-run mode:                                           ####
#### Put the "--commit" option to append records                            ####
################################################################################
```

コマンド中に
```--commit```
オプションがない場合には記録せず、上記の様にメッセージを出す。

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
を計算する。2万語を超えるリーダーについて**1冊まるごと**の読書時間を測るのは現実的ではないので、数ページを選んでその時間を記入するだけでも計算はする。第3引数には**1冊まるごと**の場合
```w```
もしくは
```whole```
を指定し、またはその測ったページ数を指定する。
第4引数の時間表現は、
```10m```
とか
```600s```
といった冗長さを許して指定できる。第5引数は総ページ数である。
* **1冊まるごと**の時間を測った場合 ```./readdone.awk o[xford] farrar w[hole] [0h]200m[0s] 88 --commit```
* **ある5ページ**の時間を測った場合 ```./readdone.awk o[xford] farrar 5 [0h]10m[0s] 88 --commit```

各リーダーの読書時間とページ数を**入力する**場合には、検索の時点で結果が1件になるまで絞る必要がある。逆に、各リーダーの読書時間とページ数を**入力しない**場合には、検索の時点で結果が1件になるまで絞る必要はなく、したがって複数のリーダーを一度に登録できる。この場合に第2引数を正規表現を指定できるのは有用である。

#### 音声併用で読んだ、またはシャドウイングした場合の記録
第5引数までの全てを記入した場合にのみ音声の速度を第6引数として指定できる
(空白文字列
```""```
はおそらく引数として受けつけられる) 。
引数の処理はしていないので、書いた文字列がそのまま
```read.done```
に載る。
* 音声を再生して読む ```./readdone.awk o[xford] farrar w[hole] [0h]200m[0s] 88 1x --commit```
* 1.5倍速で再生した ```./readdone.awk o[xford] farrar w[hole] [0h]200m[0s] 88 1.5x --commit```

#### ERF Graded Reader List に登録がない場合の記録
第1引数に出版社・ブランド名のかわりに ```na``` または ```NA``` を指定し、以下第2引数は書名、第3引数は著者名、第4引数は語数を指定する。読書速度を算出するための第5引数以降の順序は同様である。
空白を含む書名や著者名は
```"The Title of The Book"```
や
```'The Name of The Author'```
のように
(二重または一重)
引用符で囲む。

* 時間を測らない場合 ```./readdone.awk n[a] booktitle author wordcount --commit```
* 時間を測る場合 ```./readdone.awk n[a] booktitle author wordcount w[hole] 1h20m30s 88 --commit```

### 表示

```./mktable.awk``` (非要約モード) 長くなるためUN*Xコマンド```tail```と併用するとよい。

```./mktable.awk w``` (累計語数のみ表示)

```./mktable.awk s OBW5``` (要約モード) 第二引数は正規表現(ERE)の場合、引用符が必要。

```./mktable.awk -s s OBW5``` (要約モード) 画面を保存する。
