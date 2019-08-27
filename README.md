# extensive-reading-logger

Making use of
[Graded Reader List](https://sites.google.com/site/erfgrlist/)
provided by ERF (Extensive Reading Foundation) as a list of
tab-separated values (.tsv), **extensive-reading-logger** which consists of AWK scripts make reading records in extensive reading with ```readdone.awk```
and show them as a table with ```mktable.awk```.
The scripts has the same as some functions of UN*X commands ```grep, cat```,
and they provide users with the much simpler way. <!-- to search, to log, and to show your records -->
The scripts make graded readers as well as ordinary paperbacks recorded,
with the aid of websites like [Reading Length](https://readinglength.com/).

**extensive-reading-logger**
は、ERFが提供するグレイデッド・リーダー
(以下「リーダー」と呼ぶ)
のリスト
[ERF Graded Reader List](https://sites.google.com/site/erfgrlist/)
(.tsv, tab-separated values)
を用いて、多読を記録
(```readdone.awk```)
・表示
(```mktable.awk```)
する
AWK
(GNU Awk)
スクリプト
(とシェルスクリプト)
群である。リストの検索、多読の記録・表示といった機能は
UN*X
コマンド
```grep, cat```
による基本的な結果と同様のものである。このスクリプト群を利用すると使用者の手順を直接コマンド操作よりもっと簡潔にできる利点がある上に、さらに累計語数や
WPM
の計算、長い一冊を分割して記録するといったこともできる。リーダーではない読書の記録にも対応し、その語数も任意で記録するかどうかを決められる。その場合の語数については
[Reading Length](https://readinglength.com/)
などから探すか、または
[SSS式算出法](https://www.seg.co.jp/sss/word_count/how-to-count.html)
を用いて手動で算出する必要がある。<!-- ただしその場合もエディタ等の手書きで記録を更新する必要はない。 -->
累積語数は15桁
(100兆語)
までカラムが崩れずに表示される。

## インストール方法
このスクリプト群は
GNU Awk
```gawk```
が必要である。
このスクリプト群をインストールするには、サイト
[ERF Graded Reader List](https://sites.google.com/site/erfgrlist/)
から現時点でスクリプト
```readdone.awk```
で指定できる出版社・ブランド
に対応した
GR
リスト
(.tsv
ファイル, このフォーマットは
Google Spreadsheets
のエクスポート機能として用意されている)
をユーザー自身でダウンロードしてディレクトリ
```db/```
下に置き、アプリケーションルートディレクトリから、それら
.tsv
ファイルへのシンボリックリンクを張る。出版社名とシンボリックリンク名の既定の対応は以下の通りとしている：

出版社・ブランド|シンボリックリンク名
-----------------|-------------
Black Cat - Cideb|```blackcat```
Cambridge U. Press|```cambridge```
Cengage/Heinle|```cengage```
Macmillan ELT|```macmillan```
Oxford U. Press|```oxford```
Pearson English Readers, Penguin ELT|```pearson, penguin```

この作業は煩雑であるので、ダウンロードして以降の作業を自動で行うスクリプト
```install.sh```
をリリースに含めている。
GR
リスト自体をリリースに含めてよいかどうかは、今後
ERF
に問い合わせる予定である。

## 構成物
以下にある、「読書記録ファイル」の既定のファイル名は
```read.done```
としている。

1. ```readdone.awk``` 検索と記録。結果は読書記録ファイルに書き込まれる。
1. ```mktable.awk``` 多読記録の表示。読書記録ファイルが必要。
1. ```install.sh``` [ERF Graded Reader List](https://sites.google.com/site/erfgrlist/) をインストールする。

以下はおまけである。

1. ```accum.sh``` 累計語数の推移を視覚的に表現する。目盛りは線形と対数から選べる。読書記録ファイルが必要。
1. ```calc-audioWPM.sh``` iTunesからエクスポートされたプレイリストから、音源の読み上げ速度を計算する。
1. ```calc-audioWPM.awk``` 上記の awk 版であり、機能に差はない。
1. ```dailycount.sh``` 1日単位の語数を表示する。読書記録ファイルが必要。長くなるためUN*Xコマンド```tail```と併用してもよい。
1. ```deviation.awk``` シリーズ語数平均からの各リーダーの偏差 (散らばり) を表示する。
1. ```read.done``` 読書記録ファイルの実施例である。これを用いて一通りの動作を確認できる。<!-- 私自身のバックアップを兼ねてもいる。 -->

## 使用方法
以下に使用方法を説明する。大きくわけて
1. ```./readdone.awk``` リーダーのタイトルや語数を検索
1. ```./readdone.awk --commit``` 検索したリーダーの記録
1. ```./mktable.awk``` 表示

の三通りがある。
記録については、ただ必要項目を記録するだけでなく、「どのように読んだか」
(詳述する)
についても記録できる方法を提供している。
表示については、非要約モードと要約モード、さらに非要約モードより冗長な饒舌モード、デバッグモードといった挙動を提供している。
以下に、順を追って説明する。

### 検索
目的のリーダーのタイトルと書誌データを検索するためのコマンドは
```readdone.awk```
である。
記録に必要なリーダーを選ぶためには、
* 第1引数にリーダーの出版社名・ブランド名、
* 候補を絞るために第2引数に検索キーワード、
を指定する。

出版社・ブランド名入力の必要性は同一著者からの同名タイトルが複数存在するためで、それらの区別はユーザー側でつけてほしい。<!-- 今後、この指定を外せるか試す予定ではあるが、一意に指定するためにはいずれにせよユーザーが区別しないといけないのは同じなので、殆ど意味はないと思う。 -->
例えば、
Oxford Bookworms Library
や
Oxford Reading Tree
などを出版するオックスフォード大学出版局のリーダーを指定したい場合、第1引数は
```oxford```
とする。または可能な限り省略して
```o``` ともできる。<!-- この -->
<!-- ```o[xford]``` -->
<!-- の他に第1引数で指定できる出版社・ブランドは、現時点で本邦で入手しやすい -->
<!-- ```b[lackcat], ca[mbridge], ce[ngage], m[acmillan], pen[guin], pea[rson]``` -->
<!-- である。 -->

検索キーワードとして例えば、
Brat Farrar, Oxford Bookworms Library Stage 5
を指定したい場合、第2引数では大文字と小文字を区別せず、また拡張正規表現
(ERE)
も指定でき、その場合には(二重)引用符が必要である。以下の例では単に
```farrar```
と普通の文字列検索として指定している。

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
オプションがない場合には読書記録ファイルに記録せず、上記の様に警告メッセージを出す。

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
```100m```
とか
```600s```
といった冗長さを許して指定できる。第5引数は総ページ数である。
* **1冊まるごと**の時間を測った場合 ```./readdone.awk o[xford] farrar w[hole] [0h][200m][0s] 88 --commit```
* **ある5ページ**の時間を測った場合 ```./readdone.awk o[xford] farrar 5 [0h][10m][0s] 88 --commit```

各リーダーの読書時間とページ数を**入力する**場合には、検索の時点で結果が1件になるまで絞る必要がある。逆に、各リーダーの読書時間とページ数を**入力しない**場合には、検索の時点で結果が1件になるまで絞る必要はなく、したがって複数のリーダーを一度に登録できる。この場合に第2引数を正規表現を指定できるのは有用である。

#### 第6引数を指定すると「どのように読んだか」を記録できる
第5引数まで全て指定した場合に第6引数を指定できる
(空白文字列
```""```
は第5までの引数として受けつけられる)
。引数に書いた文字列がそのまま
```read.done```
に載るしくみなので利用者が好みの記法を導入してこれを備考欄として扱えばよい。
特に、多読の第三原則「投げ出した」場合や、1冊を何度かに分けて読んだ場合、音声を併用した場合などについては既定の記号があり、それに対して
```mktable.awk```
は特定の動作を返す。

#### 多読の第三原則「投げ出した」場合の記録
挫折するまでに読んだページ数、時間、総ページ数を指定した次の位置で第6引数
```quit```
を指定する。このとき、挫折するまで読んだページが
```w[hole]```
になることはありえないのでこれをチェックする。

* 途中で読むのをやめた場合 ```./readdone.awk o[xford] farrar 15 [0h][20m][0s] 88 quit --commit```

#### 1冊を何度かに分けて読んだ (分割した) 場合の記録
第6引数で分割を指定でき、1冊を多レコードに分けて記録できる。各レコードは上から1度走査されるだけなので、レコードの種類は3種類あり、分割の始めで中座したことを示す
```suspended```
と、分割の中ほどで再開しかつまた中座したことを示す
```res+sus```
と、分割の最後の部分を再開したことを示す
```resumed```
の3種類の指定が必要である。分割開始と分割終了以外のレコードの第6引数は全て
```res+sus```
である。分割は他の作品と並行させることができる。

1. まず31ページの中程まで読んだ ```./readdone.awk o[xford] farrar 30.5 58m28s 88 suspended --commit```
2. 次に60ページの終りまで読んだ ```./readdone.awk o[xford] farrar 60 1h1m10s 88 res+sus --commit```
3. 61ページから終わりまで読んだ ```./readdone.awk o[xford] farrar w 56m54s 88 resumed --commit```

<!-- OBW5	Brat Farrar	Josephine Tey, Retold by Ralph Mowat	4.5-5.0	24510 	2019.01.04	30.5	58m28s	88	suspended -->
<!-- OBW5	Brat Farrar	Josephine Tey, Retold by Ralph Mowat	4.5-5.0	24510 	2019.01.04	60	1h1m10s	88	res+sus -->
<!-- OBW5	Brat Farrar	Josephine Tey, Retold by Ralph Mowat	4.5-5.0	24510 	2019.01.04	w	56m54s	88	resumed -->

#### 音声併用で読んだ、または音読した場合の記録
音声の速度を第6引数として指定できる。第6引数で指定した文字列がそのまま
```read.done```
に載る。音読やシャドウイングを語数に数えるかどうかは各自の自由にすればよい。

* 音声を再生して読む ```./readdone.awk o[xford] farrar w[hole] [0h]200m[0s] 88 1x --commit```
* 1.5倍速で再生した ```./readdone.awk o[xford] farrar w[hole] [0h]200m[0s] 88 1.5x --commit```

#### ERF Graded Reader List に登録がない場合の記録
第1引数に出版社・ブランド名のかわりに
```na```
または
```NA```
を指定し、以下第2引数は書名、第3引数は著者名、第4引数は語数を指定する。読書速度を算出するための第5引数以降の順序は同様である。空白を含む書名や著者名は
```"The Title of the Book"```
や
```'The Name of the Author'```
のように
(二重または一重)
引用符で囲む。

* 時間を測らない場合 ```./readdone.awk n[a] booktitle author wordcount --commit```
* 時間を測る場合 ```./readdone.awk n[a] booktitle author wordcount w[hole] 1h20m30s 88 --commit```

### 表示

#### 非要約モード
```read.done```
に記載された記録を整形して表にする。1レコードに1行を使用し表が長くなるため後述の要約モードが
(多読のやりかたによっては)
有用かもしれない。
 <!-- UN*X コマンド ```tail,head,grep``` と併用するか、 -->
* ```./mktable.awk``` WPMが色つきで表示される。速さとその意味とその色との関係は以下の通りであり、速さの意味は酒井『快読100万語』[1]におおよそ倣った。
* ```./mktable.awk -w``` 画面を保存する。

速度|WPMの色|意味
-----------------|-------------|------
200-|![#00ffff](https://placehold.it/15/00ffff/000000?text=+) `シアン(#00ffff)`|十分に速いので、レベルを上げよう
150-200|![#005fff](https://placehold.it/15/005fff/000000?text=+) `ドッジブルー(#005fff)`|レベルを上げてよいか、留まってもよい
100-150|無色|このレベルが現在の訓練に適している
75-100|![#ffff00](https://placehold.it/15/ffff00/000000?text=+) `イエロー(#ffff00)`|読むのが辛ければレベル下げを検討すべき
-75|![#ff0000](https://placehold.it/15/ff0000/000000?text=+) `レッド(#ff0000)`|おそらく難しすぎる


使用例:

```
$ ./mktable.awk
---------------------------------------------------------------------------------------------------------------
Date		Words	Sum	CEFR	audio	min/p	words/m	Reader	Title
---------------------------------------------------------------------------------------------------------------
2017.01.17	  1292	   1292	A1				OBWS	Cat, The
2017.01.17	   890	   2182	A1				OBWS	Connecticut Yankee in King Arthur's Court, A
2017.01.19	  1260	   3442	A1				OBWS	Dead Man's Money
2017.01.19	  1400	   4842	A1				OBWS	Drive into Danger
2018.01.21	  5440	  10282	A1/A2		0.6 m/p	220 wpm	OBW1	Wizard of Oz, The
                                        .
                                        .
                                        .
2018.12.20	 24045	8932039	B2		2.3 m/p	120 wpm	OBW5	Great Expectations
2018.12.21	 22885	8954924	B2		2.6 m/p	101 wpm	OBW5	Riddle of the Sands, The
2018.12.21	     0	8954924	B2	quit	5.2 m/p	 53 wpm	OBW5	Sense and Sensibility
2018.12.22	 24810	8979734	B2	N/A	2.6 m/p	106 wpm	OBW5	Accidental Tourist, The
2018.12.22	 15250	8994984	B1/B2	N/A	1.6 m/p	130 wpm	OBW4	African Queen, The
2018.12.23	 24750	9019734	B2		1.7 m/p	163 wpm	OBW5	This Rough Magic
---------------------------------------------------------------------------------------------------------------
Cumulative Total: 885 books, 9019734 words read
```
「投げ出した」場合の記録については、その行の
```audio```
欄に
```quit```
と表示される。また、読了したのべ冊数にも数えないし、その本の語数も数えないので語数は0である。

1冊を分割して記録した場合については、どの1冊も1つのレコードで表示するのが既定の動作である：
```
$ ./mktable.awk
                                        .
                                        .
2019.01.04	  24510	9235955	B2	N/A	2.0 m/p	139 wpm	OBW5	Brat Farrar	
2019.01.05	  22620	9258575	B2	N/A	1.7 m/p	158 wpm	OBW5	Bride Price, The	
---------------------------------------------------------------------------------------------------------------
Cumulative Total: 897 books, 9258575 words read
```

#### 饒舌(冗長)モード
ただし、オプション
```-v```
を指定した
(```awk, gawk```
インタプリタへのオプションとインタプリタが混同してしまわないように、第1引数には
```--```
を置き、本スクリプト
```mktable.awk```
自体へのオプションは第2引数以降で指定する必要がある)
場合には分割した通りにレコードを表示する。また、各レコードの第5カラムでは、一冊全体に対する読書進捗状況が百分率で表示される。

```
$ ./mktable.awk -- -v
                                        .
                                        .
2019.01.04	      0	9211445	B2	 35%	1.9 m/p	145 wpm	OBW5	Brat Farrar	
2019.01.04	      0	9211445	B2	 68%	2.0 m/p	140 wpm	OBW5	Brat Farrar	
2019.01.04	  24510	9235955	B2	100%	2.0 m/p	139 wpm	OBW5	Brat Farrar	
2019.01.05	      0	9235955	B2	 52%	1.7 m/p	160 wpm	OBW5	Bride Price, The	
2019.01.05	  22620	9258575	B2	100%	1.7 m/p	158 wpm	OBW5	Bride Price, The	
---------------------------------------------------------------------------------------------------------------
Cumulative Total: 897 books, 9258575 words read
```

#### 要約モード
のべ語数よりWPMを上げるのが目的で多読を行い、しかも同じタイトルのリーダーを複数回読む流儀の多読には、各タイトルが当初の読みに比べてどれだけ改善したかを示す「要約モード」が有用な場合もあろう。同一タイトルの読書記録は同じ行にできるだけ詰めて表示され、
WPM
の伸び(または縮み)を見ることができる。
第二引数は正規表現(ERE)の場合、引用符が必要である。
* ```./mktable.awk s OBW5``` WPMが色つきで表示される。
* ```./mktable.awk -w s OBW5``` 画面を保存する。

2018年12月某日に起動した場合の使用例:

タブ幅に納まる様に記述を圧縮している。
```169@Nov```
は今年の11月のある日に読んだ結果、169 WPM だったことを表す。今年(2018年)以外の記録は全て西暦年の下2桁のみを用いる:
```n/a@'15```
は2015年に読み、しかも時間を測らなかったのでWPMが計算できないことを表す。同様に、
```128@'17```
は2017年のある日の
128 WPM
という結果である。
今年の今月に読んだものは、たとえば
```130@22 ```
のように月の日だけ(22日)が表示される。
<!-- プログラム -->
<!-- ```./mktable.awk s``` -->
<!-- を呼び出した日の月が「今月」、また呼び出した日の年が「今年」である。 -->


```
$ ./mktable.awk s OBW4$
OBW4	20,000 Leagues under the Sea				152@Apr	165@Jun	160@Sep	150@Oct	169@Nov
OBW4	African Queen, The				N/A	 72@'17	 93@Apr	101@Jun	173@Aug	130@Nov	130@22
OBW4	Big Sleep, The					N/A	128@'17	144@Apr	149@Jun	229@Aug	210@Nov
                                        .
                                        .
                                        .
OBW4	We Didn't Mean to Go to Sea			N/A	131@May	155@Jul	145@Sep	162@Oct	172@Nov
OBW4	Whispering Knights, The				N/A	n/a@'15	154@May	166@Jul	141@Sep	181@Nov
```

#### 累計語数のみ表示

* ```./mktable.awk w```

使用例:

```
$ ./mktable.awk w
9019734
```

## 参照文献
1. 酒井邦秀『快読100万語!ペーパーバックへの道』(ちくま学芸文庫、2002年)
