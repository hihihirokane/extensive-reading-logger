# extensive-reading-logger

Making use of
[Graded Reader List](https://sites.google.com/site/erfgrlist/)
provided by ERF (Extensive Reading Foundation) as a list of
tab-separated values (.tsv), these AWK scripts make records and show
them as a table in your activity of extensive reading.

ERFが提供するグレイデッド・リーダーのリスト
[ERF Graded Reader List](https://sites.google.com/site/erfgrlist/)
(Tab-separated values)を用いて、多読を記録・表示するawkスクリプト。グ
レイデッドリーダーでないものは手書きで更新する必要があるが、
`mktable.awk` はその場合も考慮して表示する。


## Components

1. ```readdone.awk``` 検索と記録。
1. ```mktable.awk``` 多読記録の表示。

## How to Use

### 検索

第二引数は正規表現を受けつけるものの引用符が要るかもしれない。

```./readdone.awk o[xford] farrar w[hole] [0h]200m[0s] 88```

<!-- `o[xford], penguin(pearson), cambridge, cengage(heinle),
macmillan, blackcat` のみを用意している。 -->

### 記録

```./readdone.awk o[xford] farrar w[hole] [0h]200m[0s] 88 --commit```

### 表示

```./mktable.awk``` (非要約モード)

```./mktable.awk w``` (累計語数のみ表示)

```./mktable.awk s OBW5``` (要約モード、 第二引数は正規表現を受けつけるものの引用符が要る？)
