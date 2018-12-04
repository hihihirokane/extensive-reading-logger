# extensive-reading-logger

Making use of
[Graded Reader List](https://sites.google.com/site/erfgrlist/)
provided by ERF (Extensive Reading Foundation) as a list of
tab-separated values (.tsv), you can make reading records in extensive reading with ```readdone.awk```
and show them as a table with ```mktable.awk```. These AWK scripts not only allow graded readers but also ordinary paperbacks to be recorded.

ERFが提供するグレイデッド・リーダーのリスト
[ERF Graded Reader List](https://sites.google.com/site/erfgrlist/)
(Tab-separated values)を用いて、多読を記録・表示するawkスクリプト。グ
レイデッドリーダーでないものは手書きで ```read.done``` を更新する必要
があるが、`mktable.awk` はその場合も考慮して表示する。


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

第二引数には検索キーワードを置く。大文字と小文字を区別しない。また第二
引数は正規表現(ERE)の場合、引用符が必要。

```./readdone.awk o[xford] farrar w[hole] [0h]200m[0s] 88```

<!-- `o[xford], penguin(pearson), cambridge, cengage(heinle),
macmillan, blackcat` のみを用意している。 -->

### 記録
各本の読書時間とページ数を入力する場合には、検索の時点で結果が1件にな
るまで絞る必要がある。

```./readdone.awk o[xford] farrar w[hole] [0h]200m[0s] 88 --commit```

### 表示

```./mktable.awk``` (非要約モード) 長くなるので```tail```コマンドと併用するのがよい。

```./mktable.awk w``` (累計語数のみ表示)

```./mktable.awk s OBW5``` (要約モード) 第二引数は正規表現(ERE)の場合、引用符が必要。
