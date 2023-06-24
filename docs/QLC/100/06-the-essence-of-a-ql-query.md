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
まずは、クエリファイル`PuzzleOneAttemptOne.ql`を作成します。
そして、`PuzzleOne`ディレクトリの下に、対応するQLのテストも作成します。

```
ql file=./src/solutions/PuzzleOneAttemptOne.ql
```

このクエリを実行すると、次のような結果を見ることできます。

```
diff file=./tests/solutions/PuzzleOneAttemptOne.expected
```
正解の結果は、`D` `C` `B` `E` `A`となります。

しかし、このクエリは、*elegant*ではないです。最終結果を手動で構築しなければなりません。競技者を追加した場合を考えて見ましょう。例えば、最大1024人になった場合を想像して見ましょう。もう手に負えないことが想像できると思います。2人の競技者間の関連性を見つけるより良い解決策が必要です。

ロジックの中で、*predicate* は属性もしくは、依存関係を表現します。ロジック言語ではあるQLはpredicateをサポートします。
`PuzzleOneAttemptTwo.ql`クエリファイルと、それに対応したQLテストを作成します。そのクエリファイルの中で、predicate宣言した`finishesBefore`を定義します。このpredicateは競技者間の依存環境をキャプチャします。

```
ql file=./src/solutions/PuzzleOneAttemptTwoA.ql
```
`codeql test run`を実行して、そこで生成されたデータベース`PuzzleOne.testproj`をマウントします。
Run the `PuzzleOneAttemptTwo.qlref` test and mount the test database `PuzzleOne.testproj` of the failed test. Note that the test database has the name of the test directory, because the parent directory of each `.qlref` file is used to construct a test database.

テストデータベースをマウントして、predicate`finishesBefore`をテストします。Visual Studio Code Editorは簡単に評価について、ヒントを提供します。

![img](/assets/images/QLC/100/quick-evaluation.png "Quick evaluating hint on `finishesBefore` predicate.")

predicate`finishesBefore`の簡単な評価は、PuzzleOneAttemptTwoA.expectedと同一になることです。:

```
ql file=./tests/solutions/PuzzleOneAttemptTwoA.expected
```

簡単な評価機能は、ロジックをデバッグする際に、ちょー役立つものです。さらにVisual Studio Codeによって提供されるヒントに加え、*formulas*, *expressions*, *types*を選択でき、`CodeQL: Quick Evaluation`コマンドを使って、それらを検証できます。

![img](/assets/images/QLC/100/partial-quick-evaluation.png "Quick evaluating the first two disjunctions.")

フィニッシュ順を見つけるために、predicate`finishesBefore`で生成された配列(タプル)に*接続*します。例えば、部分的にフィニッシュ順を取得するために`(D, C)` と `(C, B)`と表現します。1つのpredicateの二番目の引数は別のコールの一番目の引数となります。

<details><summary>Implement a query to find the partial finish order `D C B` using the `finishesBefore` predicate.</summary>

```ql
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

The following example demonstrates how recursion can be used to find all the finishers after a certain finisher. Note that we renamed the predicate `finishesBefore` to `finishesBeforeStep` to highlight it is a step function.

```ql file=./src/solutions/PuzzleOneAttemptTwoB.ql#L1-L17

```

The base case is our step predicate `finishesBeforeStep`, finding all the finishers reachable with a single step. The recursive case uses the [quantified formula](https://codeql.github.com/docs/ql-language-reference/formulas/#quantified-formulas) [exists](https://codeql.github.com/docs/ql-language-reference/formulas/#exists). Quantified formulas allow us to introduce temporary variables that we can use in the formula's body to create new formulas from existing ones. The `exists` formula has the syntax `exists(<variable declarations> | <formula>)`. The syntax used in our example, `exists(<variable declarations> | <formula1> | <formula2>)`, is equivalent to `exists(<variable declarations> | <formula1> and <formula2>)`.

We use the `exists` to create a new formula from the predicate `finishesBeforeStep` and the predicate `finishesBefore` to find another racer that we can reach with a single step and all the racers that reachable from that other racer.

Quick evaluating the new `finishesBefore` predicate provides us with the result:

```ql file=./tests/solutions/PuzzleOneAttemptTwoB.expected
```

Because this type of recursion is very common QL has implemented a shortcut that computes a [transitive closure](https://codeql.github.com/docs/ql-language-reference/recursion/#transitive-closures) of a predicate. The transitive closure is obtained by repeatedly calling a predicate.

QL has two types of transitive closures. The transitive closure `+` that calls a predicate one ore more times. The reflexive transitive closure `*` calls a predicate zero or more times. The transitive closure of a predicate call can be used by appending a `+` or a `*` to the predicate name in a predicate call.

Using our step function we can compute the transitive closure by calling it as `finishesBeforeStep+(racerOne, racerTwo)`.

The transitive closure cannot be used on all predicate calls. The predicate must have two arguments with types that are [compatible](https://codeql.github.com/docs/ql-language-reference/types/#type-compatibility).

<details><summary>Write a query that uses the transitive closure of the predicate `finishesBeforeStep` to compute the same results as the recursive predicate `finishesBefore`.</summary>

```ql file=./src/solutions/PuzzleOneAttemptTwoC.ql#L11-L14

```

</details>

To determine if the results are the same you can use the `Compare Results` option in the `Query History` pane of the CodeQL extension.

Select to last two items in the history, right-click, and select `Compare Results`. This should result in an empty comparison.

![img](/assets/images/QLC/100/compare-results.png "Compare query results")

With our transitive closure we are almost done with finding the finish order. First we want to limit the reachable racers from the first finisher. Secondly we want a single answer.

Let's continue with determining which racer is the first to finish.

<details><summary>How can you determine who is the first finisher?</summary>

The first finisher is a finisher with no finisher before them. That is, it is not the case there exists another finisher that finishes before the first one.

</details>

In QL you can negate a formula by prepending a `not` to that formula. For example, the following query returns all pairs where `racerOne` does not finish before `racerTwo`.

```ql file=./src/solutions/PuzzleOneAttemptTwoD.ql#L11-L16
```

The extra equality expressions for `racerOne` and `racerTwo` are required because we can't determine the range of values for `racerOne` and `racerTwo` from a negation. That is, `not` is not [binding](https://codeql.github.com/docs/ql-language-reference/evaluation-of-ql-programs/#binding). Without those the CodeQL will give an error that `racerOne` and `racerTwo` are not bounded to a value. This is caused by the fact that many of the primitive types including `string` are infinite. They have an infinite number of values. Since QL can only work with finite results we need to restrict the set of values for the result. Before, that was done by the `finishesBeforeStep` predicate.

To restrict the set of values we use the member predicate `charAt` that expects an index. We, however, are not interested in a particular index so we pass the [dont'-care expression](https://codeql.github.com/docs/ql-language-reference/expressions/#don-t-care-expressions). That is any value which will result in calling the predicate with all the indices binding the racers to the characters `["A", "B", "C", "D", "E"]`. `racerOne = "ABCDE".charAt(_)` is equivalent to `racerOne = ["A", "B", "C", "D", "E"]` where the latter is the [set literal expression](https://codeql.github.com/docs/ql-language-reference/expressions/#set-literal-expressions) we used in the very beginning.

<details><summary>Using the `not` formula, write a predicate `firstFinisher` that holds if a finisher is the first finisher. Remember, `not` is not [binding](https://codeql.github.com/docs/ql-language-reference/evaluation-of-ql-programs/#binding).</summary>

```ql file=./src/solutions/PuzzleOneAttemptTwoE.ql#L11-L14
```

</details>

With the `firstFinisher` predicate we can now limit the results to the first finisher and all those that are reachable from the first finisher.

<details><summary>Write a query that returns the first finisher and all the finisher reachable from that first finisher.</summary>

```ql file=./src/solutions/PuzzleOneAttemptTwoF.ql#L16-L18
```

</details>

So now we have the first finisher and all those that finish after. However, there are still multiple results. The last task is to [aggregate](https://codeql.github.com/docs/ql-language-reference/expressions/#aggregations) the finishers to get the final finish order.

In our case the aggregate `[[https://codeql.github.com/docs/ql-language-reference/expressions/#aggregations][concat]]` looks interesting, however, we can't properly control the order of the results which in this case is important.

That is, the following does not give the correct order because strings are sorted lexicographically.

```ql file=./src/solutions/PuzzleOneAttemptTwoG.ql#L16-L20
```

<details><summary>Why does the query use the reflexive transitive closure operator `*`?</summary>

To include the `firstFinisher` that does not have a finisher before them.

</details>

That means we need to build the final finish order ourselves, recursively. We have seen recursion and the closely related transitive closure before. In most cases the transitive closure is sufficient, but sometimes you want more control. For example when the goal is to find all the functions reachable from a function `entrypoint` that are not reachable by an authorization function to determine authentication bypasses.

In this case we want to build up the finish order from the first finisher. A recursive problem requires two cases, the base case, and the recursive case.

<details><summary>The base case determines when we are done. What would that be in our problem?</summary>

When we have reached the last finisher.

</details>

<details><summary>Implement the predicate `lastFinisher` using the already defined predicate `finishesBeforeStep`. You can take inspiration from the predicate `firstFinisher`. Remember that the `not` does not *bind*.</summary>

```ql file=./src/solutions/PuzzleOneAttemptTwoH.ql#L16-L18
predicate lastFinisher(string racer) {
    not finishesBeforeStep(racer, _) and finishesBeforeStep(_, racer)
}
```

</details>

<details><summary>Write the predicate `finishOrderFor`. QL supports [predicates with results](https://codeql.github.com/docs/ql-language-reference/predicates/#predicates-with-result). A predicate with a result is defined by replacing the keyword `predicate` with the type of the result. The result can be referenced through a special variable `result`. Semantically it is the same as predicates without a result, the result would just be a parameter, but it can result in a more readable query because you can omit a `exists`.

```ql
string finishOrderFor(string racer) {
    none() // replace with implementation
}
```

</summary>

With the predicate `finishesBeforeStep` rewritten as a predicate with a value, and the predicate `finishOrderFor` written as a predicate with a value, the complete query becomes.

```ql file=./src/solutions/PuzzleOneAttemptTwo.ql
```

The result of this query should be:

```ql file=./tests/solutions/PuzzleOneAttemptTwo.expected
```

</details>
