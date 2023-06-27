---
layout: page
title: The essence of a QL query
octicon: package
toc: false
---

クエリの基本構成をこれまで、学習してきました。引き続き、クエリの構成要素、*types*、*formulas*、*predicates*について見ていきます。

クエリの本質は、typesとvaluesの関係性です。論理パズルを解くことで、構成要素の学習と、どのように活用するのかを学習していきます。

### Predicates

簡単な論理パズルを使って、学習します。
論理パズルの説明:
- 5人の競技者`A`、`B`、`C`、`D`、`E`がいます
- それぞれ以下の条件で競技を終わります
    - `C` は、`B`の前でフィニッシュしますが、`D`の後ろでフィニッシュ
    - `E`は、`A`の前でフィニッシュしますが、`B`の後ろでフィニッシュ

上記の条件が成立する、順番はどうなりますか？

別の競技者の前に誰がフィニッシュするのかという競技者間の関連性がわかります。その関連をどのように表現しますか？

比較記述を組み合わせて整数を使ったスクリプトを作成してみます。
まずは、クエリファイル`PuzzleOneAttemptTwo.ql`を作成します。
そして、`PuzzleOneAttemptTwo`ディレクトリの下に、対応するQLのテストも作成します。

```
cp src/solutions/PuzzleOneAttemptTwo.ql src/problems
mkdir tests/problemes/PuzzleOneAttemptTwo
cp tests/solutions/PuzzleOneAttemptTwo.qlref test/problems/PuzzleOneAttemptTwo
touch tests/problems/PuzzleOneAttemptTwo.expected
```

このクエリを実行すると、次のような結果を見ることできます。

```
+| DCBEA |
[1/1 comp 91ms eval 41ms] FAILED(RESULT) /Users/yukiendo/workplace/codeql-learning-catalog/docs/QLC/100/tests/problems/PuzzleOneAttemptTwo/PuzzleOneAttemptTwo.qlref
0 tests passed; 1 tests failed:
  FAILED:
```
正解の結果は、`D` `C` `B` `E` `A`となります。

しかし、このクエリは、*elegant*ではないです。最終結果を手動で構築しなければなりません。競技者を追加した場合を考えて見ましょう。例えば、最大1024人になった場合を想像して見ましょう。もう手に負えないことが想像できると思います。2人の競技者間の関連性を見つけるより良い解決策が必要です。

ロジックの中で、*predicate* は属性もしくは、依存関係を表現します。ロジック言語ではあるQLはpredicateをサポートします。
`PuzzleOneAttemptTwoA.ql`クエリファイルと、それに対応したQLテストを作成します。そのクエリファイルの中で、predicate宣言した`finishesBefore`を定義します。このpredicateは競技者間の依存環境をキャプチャします。

```
cp src/solutions/PuzzleOneAttemptTwoA.ql src/problems
mkdir tests/problemes/PuzzleOneAttemptTwoA
cp tests/solutions/PuzzleOneAttemptTwoA.qlref test/problems/PuzzleOneAttemptTwoA
touch tests/problems/PuzzleOneAttemptTwoA.expected
```
`codeql test run`を実行して、そこで生成されたデータベース`PuzzleOneAttemptTwoA.testproj`をマウントします。

テストデータベースをマウントして、predicate`finishesBefore`をテストします。Visual Studio Code Editorは簡単に評価について、ヒントを提供します。

![img](/public/assets/images/QLC/100/quick-evaluation.png "Quick evaluating hint on `finishesBefore` predicate.")

predicate`finishesBefore`の簡単な評価は、PuzzleOneAttemptTwoA.expectedと同一になることです。:

```
| B | E |
| C | B |
| D | C |
| E | A |
```

簡単な評価機能は、ロジックをデバッグする際に、ちょー役立つものです。さらにVisual Studio Codeによって提供されるヒントに加え、*formulas*, *expressions*, *types*を選択でき、`CodeQL: Quick Evaluation`コマンドを使って、それらを検証できます。

![img](/public/assets/images/QLC/100/partial-quick-evaluation.png "Quick evaluating the first two disjunctions.")

フィニッシュ順を見つけるために、predicate`finishesBefore`で生成された配列(タプル)に*接続*します。例えば、部分的にフィニッシュ順を取得するために`(D, C)` と `(C, B)`と表現します。1つのpredicateの二番目の引数は別のコールの一番目の引数となります。

<details><summary>predicate`finishesBefore`を使って、一部のゴールする順が`D C B`を検出するクエリを実装</summary>

```
from string one, string two, string three
where one = "D" and finishesBefore(one, two) and finishesBefore(two, three)
select one, two, three
```

</details>

この部分的なフィニッシュ順については、このソリューションで機能します。しかし、変数として、競技者それぞれの表現に戻ってみます。そして、最終的なフィニッシュ順を結果を得るために、複数のpredicate callを実施する必要があります。

この繰り返し、predicate callを使うことは、探索プログラムにおける共通パターンです。そして典型的に１つの場所から別の場所へ到達できるか Step機能を利用することでどうか考慮する。具体的な例を以下に示します。:

- 関数コールを使って、`foo`が、関数`bar`に到達できるか？
- 変数の値`foo`は、関数`baz`の引数`bar`に到達することができるか？

最初にゴールした人から最後の競技者へのパスを見つけることで、到達問題として、ゴール到達順問題を利用することができます。

QLは、再帰呼び出しを使って、predicateの繰り返しアプリをサポートします。再帰predicateの中で、２つのケースを考慮しなければいけません。:

1. 基本ケースとして、完了したことを決定する。
2. 再帰呼び出しケース

次の例は、最初にゴールした人の後に、すべての人がゴールするのを確認するのに、再帰がどのように利用されるのかをデモンストレーションします。ポイントは、１つのステップで、`finishesBefore`から`finishesBeforeStep`へ名前を変更することです。

```
predicate finishesBeforeStep(string racerOne, string racerTwo) {
    racerOne = "C" and racerTwo = "B"
    or
    racerOne = "D" and racerTwo = "C"
    or
    racerOne = "E" and racerTwo = "A"
    or
    racerOne = "B" and racerTwo = "E"
}

predicate finishesBefore(string racerOne, string racerTwo) {
    finishesBeforeStep(racerOne, racerTwo)
    or
    exists(string otherRacer | finishesBeforeStep(racerOne, otherRacer) |
    finishesBefore(otherRacer, racerTwo)
    )
}
```

基本になるケースが、1 ステップですべてゴールした人を見つける`finishesBeforeStep`です。再帰呼び出しが[quantified formula](https://codeql.github.com/docs/ql-language-reference/formulas/#quantified-formulas) [exists](https://codeql.github.com/docs/ql-language-reference/formulas/#exists)を利用します。
`quantified formula(定量化する公式)`は、既存の公式から、新しい公式を作成するための公式の本体の中で利用できるような、作業用変数を使えるようにします。`exists`の文法は、`exists(<variable declarations> | <formula>)`です。文法例は、`exists(<variable declarations> | <formula1> | <formula2>)`と`exists(<variable declarations> | <formula1> and <formula2>)`は同一という例です。

1ステップで、次のゴールする人を見つけるpredicate`finishesBeforeStep`とpredicate `finishesBefore`から、新しい公式を作成するために、`exists`を使います。そして別の人からすべてのゴール人を見つけます。

結果を提供するpredicate`finishesBefore`を検証します。:

```
| B | A |
| B | E |
| C | A |
| C | B |
| C | E |
| D | A |
| D | B |
| D | C |
| D | E |
| E | A |
```

再帰は大変一般的であるため、QLは、[transitive closure](https://codeql.github.com/docs/ql-language-reference/recursion/#transitive-closures)を実行するショートカットを実装します。推移閉包(transitive closure)は、predicateを繰り返し呼び出すことで獲得します。

QLは、2つのタイプのtransitive closure(推移閉包)を持ちます。transitive closure`+`は1回以上のpredicateをコールします。再帰のtransitive closure`*`は0回を含む複数回のpredicateをコールします。predicateのtransitive closureは、predicateコールの中で、predicateに`+`もしくは`*`を追加して使用します。

今回の実装するstep functionを使うことで、`finishesBeforeStep+(racerOne, racerTwo)`として、それを呼び出すことで実行することができます。

transtitive closureは、すべてのpredicateコールで使用できるわけではありません。predicateは、[compatible](https://codeql.github.com/docs/ql-language-reference/types/#type-compatibility)にある型を持つ２つの引数である必要があります。

<details><summary>再帰呼び出しpredicate`finishesBefore`と同じ結果を実行するためのpredicate`finishesBeforeStep`のtransitive closureを使うクエリを記述</summary>

```
from string racerOne, string racerTwo
where
  finishesBeforeStep+(racerOne, racerTwo)
select racerOne, racerTwo

```

</details>
結果が同じであること決めるために、CodeQL extensionの`Query History`ペインの中の`Compare Results`オプションを利用することができる。

履歴で最後の２アイテムを選択するために、マウスを右クリックして、`Compare Results`を選択します。This should result in an empty comparison.

![img](/public/assets/images/QLC/100/compare-results.png "Compare query results")

実装したtransitive closureを使うと、ゴールの順を求めることができます。まず最初に、最初にゴール人からゴールした人数に制限をしたい。次に回答は１つにしたい。

誰が最初にゴールするのか決定するよう、作業を続けます。

<details><summary>どのようにして、最初にゴールした人を決定すれば良いですか？</summary>

最初にゴールした人は、彼らの前に誰もフィニッシュしていないことです。最初の人の前に誰もゴールした人が存在していないことを条件を満たすことです。

</details>

QLの中で、公式の先頭に`not`を追加することで、否定を意味します。例えば、次のクエリは、`raceTwo`の前に`racerOne`はフィニッシュしていないすべてのペアを返しています。

```
from string racerOne, string racerTwo
where
  not finishesBeforeStep+(racerOne, racerTwo) and
  racerOne = "ABCDE".charAt(_) and
  racerTwo = "ABCDE".charAt(_)
select racerOne, racerTwo
```

`racerOne`と`racerTwo`に関して、追加で品質の表現を必要とします。`racerOne`と`racerTwo`の取りうる値の範囲を決めることができないためです。`not`は、[binding](https://codeql.github.com/docs/ql-language-reference/evaluation-of-ql-programs/#binding)を否定することです。これらの機能なしで、CodeQLが`racerOne`、`racerTwo`の値が境界内にない場合にエラーを与えることはできないです。`string`を含むprimitiveのタイプの多くが、無限であるという事実に起因します。QLは、有限の結果で動作するため、結果に対して制限すべきです。これまでは、predicate `finishesBeforeStep`によって実施しました。

一連の値を制限するために、インデックスを引数にとるmember predicate `charAt`を使用します。しかし、[dont'-care expression](https://codeql.github.com/docs/ql-language-reference/expressions/#don-t-care-expressions)を設定した場合には、インデックスは関係ありません。競技者を`["A", "B", "C", "D", "E"]`にバインドするpredicateの結果になります。`racerOne = "ABCDE".charAt(_)` は、`racerOne = ["A", "B", "C", "D", "E"]`に等しいという意味です。レターは、[set literal expression](https://codeql.github.com/docs/ql-language-reference/expressions/#set-literal-expressions)となります。

<details><summary>`not`表現を使用すると、ゴールした人が最初の人である場合、predicate `firstFinisher`に書き込まれます。`not`は[binding](https://codeql.github.com/docs/ql-language-reference/evaluation-of-ql-programs/#binding)でないことを思い出してください。</summary>

```
predicate firstFinisher(string racer) {
    finishesBeforeStep(racer, _) and
    not exists(string otherRacer | finishesBeforeStep(otherRacer, racer))
}
```

</details>

predicate `firstFinisher`を使って、最初にゴールする人と、最初のゴールから追跡できるすべての人への追跡結果を限定することができます。

<details><summary>最初にゴールする人と、最初にゴールした人からすべてのゴールした人を返すクエリを記述します。</summary>

```
from string firstFinisher, string other
where finishesBeforeStep+(firstFinisher, other) and firstFinisher(firstFinisher)
select firstFinisher, other
```

</details>
今、最初にゴールした人、および、その後にゴールした人すべてを知ることができました。しかし、複数の結果です。最後のハンズオンは、最終のゴールした順を取得することです。[aggregate](https://codeql.github.com/docs/ql-language-reference/expressions/#aggregations)を利用します。

集合`[[https://codeql.github.com/docs/ql-language-reference/expressions/#aggregations][concat]]`は、面白そうですが、順番を適切にコントロールすることはできないです。

文字列は、辞書学上でストアされるため、正しい順を得られない。

```
from string firstFinisher, string finalOrder
where
    firstFinisher(firstFinisher) and
    finalOrder = concat(string other | finishesBeforeStep*(firstFinisher, other) | other)
select finalOrder
```

<details><summary>どうして、再帰transitive closure オペレータ`*`を使うのか？</summary>
その理由は、誰もゴールしていない`firstFinish`を含めるためです。

</details>

再帰的に最後のゴール順を構築する必要があることを意味します。前回、再帰、相対transitive closureを見ました。大抵の場合、transitive closureは効果的ですが、より制御が必要な場合もあります。例えば、ゴールが関数`entrypoint`から到達できるすべての関数を見つけることである場合、認証を回避することを決定するための許可によって到達できません。

この場合、最初のゴール人からのフィニッシュ順を構築したいです。再帰問題は、２つのケースを要求します。基本ケースと再帰ケースです。

<details><summary>基本ケースは、いつ完了するのか、それは、それら問題の中に何があるのか？</summary>

いつ、最後にゴールした人に到達しましたか？

</details>

<details><summary>先に実装したpredeicate `finishesBeforeStep`を使って、predicate `lastFinisher`を実装します。`firstFinisher`がヒントになります。`not`は*bind*しないということがヒントです。</summary>

```
predicate lastFinisher(string racer) {
    not finishesBeforeStep(racer, _) and finishesBeforeStep(_, racer)
}
```

</details>

<details><summary>predicate `finishOrderFor`を記述します。 QLは、[predicates with results](https://codeql.github.com/docs/ql-language-reference/predicates/#predicates-with-result)をサポートします。結果を持つpredicateは、結果の型を持つpredicateに置き換えることです。 結果は、特定の変数`result`で参照します。いい身的には、結果なしのpredicateと同じです。結果は、単なるパラメタですが、`exists`を入れないために、より読みやすくすることができます。

```ql
string finishOrderFor(string racer) {
    none() // replace with implementation
}
```

</summary>

値とともにpredicate`finishesBeforeStep`を書き直し、値を持ったpredicate`finishOrderFor`を実装することでクリエが完成です。

```
string finishesBeforeStep(string racer) {
  racer = "C" and result = "B"
  or
  racer = "D" and result = "C"
  or
  racer = "E" and result = "A"
  or
  racer = "B" and result = "E"
}

predicate firstFinisher(string racer) {
  exists(finishesBeforeStep(racer)) and
  not racer = finishesBeforeStep(_)
}

predicate lastFinisher(string racer) {
  not exists(finishesBeforeStep(racer)) and racer = finishesBeforeStep(_)
}

string finishOrderFor(string racer) {
  lastFinisher(racer) and result = racer
  or
  result = racer + finishOrderFor(finishesBeforeStep(racer))
}

from string firstFinisher, string finalOrder
where
  firstFinisher(firstFinisher) and
  finalOrder = finishOrderFor(firstFinisher)
select finalOrder

```

このクエリの結果は、このようになります。:

```
| DCBEA |
```

</details>
