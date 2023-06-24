---
layout: page
title: The structure of a QL query
octicon: package
toc: false
---

最初のクエリは、最もシンプルなスクリプト、`select`文以外は利用していないものでした。

ここで典型的なクエリをご紹介します。:

- Query metadata(クエリメタデータ)
- Import statements(Import宣言)
- classesとpredicates定義
- `from`, `where`, `select`文節 

上記で示したコンポーネントの最後から説明していきます。

1. `select`文節 

    QL言語は、SQLの文法に似た言語で、`select`の記載は必須で、オプションとして、`from`と`where`で構成されています。
    ```
    from ...
    where ...
    select ...
    ```

    `from`では、変数の定義する際に先頭に置き、その後に変数を宣言していきます。それぞれの変数は、型宣言の後に変数を並べていきます。複数の型とそれに伴う変数をここで宣言します。

    <details><summary>プログラムの中で、複数の型で記述される値を想像してみましょう</summary>

    例えば、プログラムの中で、すべての数字の表現、数式表現を考えてみてください。

    </details>

    次の例は、型とその値の例となります。
    - 32bitの２の補数の整数の値は、`int`型 
    - 有限の連続した16bitの文字列、ぞれぞれの文字はUnicodeの場合、`string`型 
    - データベースをクエリする際のclass `Expr`

    本ワークショップの最後の例として、*type*の代わりに*class*を使う例があります。QLの中で、*class*定義で、*type*を定義できます。
    `where`文の中で、抽出した変数の値をさらに絞り込むことができます。

    QLは、*logic programing language* で公式を構築していきます。`where`文の中で、`<epxr> <op> <expr>`のような形式、表現をすることで、論理的なリレーションを定義します。（SQLのwhere句に似ています）

    表現(Expressions)については、[Expressions](https://codeql.github.com/docs/ql-language-reference/expressions/) に詳細があります。 

    <details><summary>What determines the set of values?</summary>

    The set of values an expression evaluates to is determined by a type.

    </details>

    クエリを記述している中で、多くの表現(Expression)のしかたをご紹介します。変数の使い方については、*[variable reference](https://codeql.github.com/docs/ql-language-reference/expressions/#variable-references)*に詳細な説明がありますので、そちらもご参照ください。

    最後に、クエリの結果を得る場合には、*select*を使います。[select clause](https://codeql.github.com/docs/ql-language-reference/queries/#select-clauses)も合わせてご参照ください。クエリの結果は、カラムとローのテーブルとして共通に表現される配列の形式になります。カラムは、`select`に提供する表現によって決定することができます。*表現形式*は、**必ず** *primitive type*の値で評価する必要があります。このワークショップの後の説明で、*primitive type*についての説明があります。*class*は、`string(文字列)`変換する *member predicate*である`toString`を用意しています。

    `as`キーワードは、カラムの結果にラベルとして利用できます。そして、`select`の他の表現の中で参照できるようにしています。`order by`キーワードは、結果を並べる機能を提供します。`asc`キーワードは、結果を昇順、`desc`は結果を降順に並べ替えます。

    次にいくつか具体例を示します。
    1. 次のコンテンツを使って、`qlc-100/problems`CodeQL packに、`FromWhereSelect.ql'クエリを追加します。

        ```
        ql file=./src/solutions/FromWhereSelect.ql
        ```

    2. `tests/problems/FromWhereSelect`ディレクトリを作成して、`tests/solutions/FromWhereSelect.qlref`、`tests/solutions/FromWhereSelect.expected`を`tests/problems/FromWhereSelect`ディレクトリへ追加します。その際に、`FromWhereSelect.qlref`の中に、相対パス指定で、`FromWhereSelect.ql`が追加されていることをご確認ください。

    3. `codeql test run`で作成したテストを実行します

    テストはfailします。

    ```
    diff file=./tests/solutions/FromWhereSelect.expected
    ```

    <details><summary>failの理由を考えます</summary>

    クエリ結果が、`FromWhereSelect.expected`の中に埋め込まれた値と整合性が取れなかったためです。

    </details>

    各々のfailしたテストについて、CodeQL extensionはデータベースを保持します。それにより、failした理由を調査することができます。`FromWhereSelect`ディレクトリの中で、`FromWhereSelect.testproj`ファイルが生成されます。`CodeQL: Set Current Database`コマンドで、そのテストデータベースをVisual Studio Code上でマウントすることができます。Visual Studio Codeから、`FromWhereSelect.testproj`を右クリックして `CodeQL: Set Current Database`を選択します。

    ![img](/assets/images/QLC/100/mount-testproj.png "Select the failed test database as the current database.")

    failしたテストを調査するために、`CodeQL: Quick query`機能を使います。この機能は、マウントしてデータベースで、1回限りのクエリを即座に生成します。

    これをテストするための、手順を以下に示します。
    1. `FromWhereSelect.testproj`データベースをマウントします
    2. Visual Studio Codeのコマンドパレットから、`CodeQL: Quick Query`を選択します。

    Visual Studio Code Explorerの中で、新しいディレクトリ`Quick Queries`とその配下に`quick-query.ql`ファイルが作成されます。ファイルは次のようなimport と select文で構成されたものになります。

    ```
    import cpp

    select ""
    ```

    ![img](/assets/images/QLC/100/quick-query-folder.png "Quick query folder added to the workspace")

    `quick-query.ql`ファイルは、選択したデータベースの言語にマッチしたスケルトンを作成します。ここにデバッグ用のスクリプトを入れます。

    ![img](/assets/images/QLC/100/codeql-databases-section.png "CodeQL extension databases section")

    作成したスクリプトを実行するために、コマンドパレット、もしくは、当該ファイル上右クリックで、`CodeQL: Run Query`を選択します。

    failした理由が判明したら、再度実行しながら、修正します。空の`FromWhereSelect.expected`でテストを実行し、その後、`codeql test accept tests/problems/FromWhereSelect/FromWhereSelect.qlref`を実行することで、`FromWhereSelect.expected`の中に、評価対象データを持つことできます。

    ![img](/assets/images/QLC/100/accept-test-output.png "Accept test output")

2. Imports

    QLは、QLコードを管理し、再利用するために[modules](https://codeql.github.com/docs/ql-language-reference/modules/#modules)機能があります。 拡張子`.ql`ファイル、拡張子`.qll`のライブラリファイルは、*暗黙的に*モジュールを定義します。`import`宣言は、名前空間に、ライブラリモジュールの公開された名前(i..e, not annotated [private](https://codeql.github.com/docs/ql-language-reference/annotations/#private))をインポートするために利用する宣言です。 

    規約によって、クエリモジュールの最初の宣言は、`import`を使って言語をインポートすることです。例えば、C/C++の場合、`import cpp`と記述します。

    モジュールについては、本ワークショップ(QLC)の中では、これ以上は触れません。

3. Query metadata(クエリメタデータ)

    クエリは、結果を表示する際のユーザへ提供する情報を持ちます。これらのプロパティをクエリメタデータと呼んでいます。

    クエリメタデータはクエリファイルの先頭に配置します。詳細は、[QLDoc comment](https://codeql.github.com/docs/ql-language-reference/ql-language-specification/#qldoc-qldoc)を参照ください。QLDocコメントは、`/**`で始め、`*/`で終わるよう記述します。そして複数の行にまたがって記述できます。 QLDocの本体である*contents*は、~/\*\*~と`*/`で囲まれたテキストで記述される。それぞれの行は、`*`に従うスペースで始まります。contents(コンテンツ)とは分離されています。[contents](https://codeql.github.com/docs/ql-language-reference/ql-language-specification/#content)[CommonMark](https://commonmark.org/)で翻訳されます。クエリのプロパティは、tagsとして指定します。 tagは `@`で始まります。 どの後に、空白なしの文字列が*key*を形成します。1つの空白が、keyとvalueを分離します。

    サポートするプロパティは、[here.](https://codeql.github.com/docs/writing-codeql-queries/metadata-for-codeql-queries/#metadata-properties) に記載があります。以下の抜粋は、標準ライブラリクエリのメタデータです。

    ```
    /**
    * @name Uncontrolled data used in OS command
    * @description Using user-supplied data in an OS command, without
    *              neutralizing special elements, can make code vulnerable
    *              to command injection.
    * @kind path-problem
    * @problem.severity error
    * @security-severity 9.8
    * @precision high
    * @id cpp/command-line-injection
    * @tags security
    *       external/cwe/cwe-078
    *       external/cwe/cwe-088
    */
    ```

    GitHub Code Scanningの結果を利用する際の重要な情報をいくつか紹介します。

    - `@name` 属性(プロパティ)は **必須(required)** クエリの表示する名前を定義します。[metadata style guide](https://github.com/github/codeql/blob/master/docs/query-metadata-style-guide.md#query-name-name)は、ピリオドなしの、大文字のセンテンスを使うよう指示しています。
    - `@description` 属性は **必須required**で、簡潔なヘルプメッセージを記述します。[meta data style guide](https://github.com/github/codeql/blob/main/docs/query-metadata-style-guide.md#query-descriptions-description) は、ピリオドで完結する、大文字のセンテンスを使って、完結な文章での記述を指示しています。
    - `@id` 属性は、 **必須required**項目で、クエリを一意に認識できるように設定する必要があります。*launguage code*で始まり、`/`がその後に記述する、CodeQLの規約に従う*必要*があります。そのあとは、短い名詞で構成すべきです。例えば、`cpp/command-line-injection` さらに、言葉はグループクエリに追加することが可能です。例えば、`js/angular-js/missing-explicit-injection`と`js/angular-js/dpulicate-dependency`
     **Note: Code Scanningは、alertsの追跡にidを利用します。idの変更は、クローズした過去のidのalertとなったり、逆に新しいidが間違って、alertとして登録されてしまう危険があります。**
    - `@kind` 属性は、 **必須required**項目で、複数のクエリタイプがありますが、ほとんど、`problem`か`path-problem`になります。kind属性は、クエリの結果をどう表示するのかを決定します。そして、特定の`select`形式を想定しています。[Defining the results of a query](https://codeql.github.com/docs/writing-codeql-queries/defining-the-results-of-a-query/) と [Creating path queries](https://codeql.github.com/docs/writing-codeql-queries/creating-path-queries/#creating-path-queries)に記載があります。
    - `@precision` 属性は、クエリをアラートするために指定します。*optional*です。 予想(期待)される正しい検出の度合いを示す:
        - `low`, 多くの誤検知の可能性。
        - `medium`, 誤検知の比率はある程度あり。
        - `high`, 誤検知は低いこと。
        - `very-high`, 誤検知はほぼないことを期待。
    - `@problem.severity` 属性は、*optional*で、 クエリのアラートに関する重症度を示す。:
        - `error`, クラッシュ、もしくは、脆弱性のような、不適切なプログラムの振る舞いになる
        - `warning`, 問題を起こす可能性
        - `recommendation`, コードが適切に動作するが、改善を期待
    - `@tags` 属性は、*optional*で、 クエリをカテゴリ別グルーピングするために利用する。共通のタグとして: `correctness`, `maintainabilility`, `readability`, `security`。  その他の利用ケースとして、[CWE](https://cwe.mitre.org/) や[OWASP Top 10](https://owasp.org/Top10/)で分類される脆弱性の分類で利用する。 例えば、`external/cwe/cwe-119`のようなCWEでの分類。
        - 追加の `@security-severity` 属性は、`security`タグとともに利用できる属性です。 重症度の範囲は、`0.0` - `10.0`の範囲で設定できます。合わせてブログ[CodeQL code scanning: new severity levels for security alerts](https://github.blog/changelog/2021-07-19-codeql-code-scanning-new-severity-levels-for-security-alerts/)の中で、重症度の計算方法について記述しています。

    クエリの属性は、どのクエリがクエリスイート[CodeQL query suite](https://codeql.github.com/docs/codeql-cli/creating-codeql-query-suites/#filtering-the-queries-in-a-query-suite)の一部なのかフィルタリングするために利用できます。QLCワークショップでは、議論の対象外となります。
