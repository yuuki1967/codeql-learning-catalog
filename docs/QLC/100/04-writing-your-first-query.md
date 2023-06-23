---
layout: page
title: Writing your first QL query
octicon: package
toc: false
---

クエリとテストCodeQL packを作成したので、ついに最初のクエリの作成に入ります。

`qlc-100/problems` CodeQL packの中に`HelloWorld.ql` ファイルを作成します:

```
c file=./src/solutions/HelloWorld.ql
```

最初のクエリになります。このクエリに対して、単体テストを実施するために、`qlc-100-tests/problems` CodeQL packに次のように追加します

1. `qlc-100-tests/problems`ディレクトリに`HelloWorld`サブディレクトリを作成する:
2. `HelloWorld`ディレクトリに、`HelloWorld.qlref`を作成して、以下の内容を入れる:

    ```
    c file=./tests/solutions/HelloWorld.qlref
    ```

3. `HelloWorld`ディレクトリに`HelloWorld.expected`を作成して、以下の内容を入れる:

    ```
    c file=./tests/solutions/HelloWorld.expected
    ```

`HelloWorld.qlref`は、テストする参照クエリを指定します。CodeQL packへの相対パスで指定します。

<details><summary>How does CodeQL know which CodeQL pack?</summary>

CodeQLは、どのCodeQL packがクエリを含むのか決定するために依存関係を検索します。

</details>

クエリ参照の代わりに、直接クエリファイルの指定も可能です。しかし、CodeQL packは、他のCodeQL packと独立してインストールできるので、通常は分離します。

`HelloWorld.expected` は、データベースをクエリしたときの期待する結果をあらかじめ入れます。 このデータベースは、`HelloWorld`ディレクトリにあるファイルから構築されたものです。このワークショップにおいては、対象ファイルがないため、データベースは空です。

テストで使用するqlpackの仕様では、 CodeQL extensionの依存性を持った[Test Explorer UI](https://marketplace.visualstudio.com/items?itemName=hbenl.vscode-test-explorer) を使ってテストを実行します。

![img](/assets/images/QLC/100/test-explorer-ui-extension.png "The HelloWorld test listed in the Test Explorer UI")

Test Explorer UI、もしくはターミナルからテストできます。

```bash
codeql test run tests/problems/HelloWorld
```
いずれにしても、テストエオ実行すると、次のようなエラーになります。

```bash
Error: Could not locate a dbscheme to compile against.
You probably need to specify a libraryPathDependencies list in
/.../src/qlpack.yml
```

`qlc-100/problems` CodeQL packの中の作成したクエリへのデータベーススキーマをテストは定義することができません。それぞれのCodeQL データベースは、言語別データベーススキーマに完全にマッチしています。そして、それぞれのクエリは、適切なデータベースをクエリするために同じスキーマにマッチする必要があります。データベーススキーマは、正しくクエリするために、それぞれの言語の標準ライブラリ`all`に入っています。

言語ごとのデータベーススキーマを選択する必要があります。その方法は、`qlc-100/problems`の`qlpack.yml`を以下のように修正することです。

```yaml
---
library: false
name: qlc-100/problems
version: 0.0.1
dependencies:
  "codeql/cpp-all": "*"
```

依存関係を解決するためには、以下のコマンドを実行します。:

```bash
▶ codeql pack install src/problems
Dependencies resolved. Installing packages...
Install location: /.../.codeql/packages
Package install location: /.../.codeql/packages
Already installed codeql/cpp-all@0.4.3 (library)
```

`qlc-100/problems`のCodeQL pack経由で、`qlc-100-test/problems` CodeQL packは、`codeql/cpp-all`の依存関係を持つ。そのため、以下のコマンド実行で、依存関係を解決します。:

```bash
▶ codeql pack install tests/problems/HelloWorld
Dependencies resolved. Installing packages...
Install location: /.../.codeql/packages
Package install location: /.../.codeql/packages
Already installed codeql/cpp-all@0.4.3 (library)
```

すべての依存関係を解決して、Testing Explorer UI、及びCodeQL CLIを実行します。
エラーなく完了したら、最初のクエリ作成は終了です。
