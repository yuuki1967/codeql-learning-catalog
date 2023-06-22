---
layout: page
title: Preparing your first QL query
octicon: package
toc: false
---

開発環境の設定が完了したら、クエリを作成することができます。本ワークショップにおいて、`https://github.com/codeql-workshops/codeql-learning-catalog`をクローンして、 `docs/QLC/100/src/problems` ディレクトリに作成したクエリを保存します。以下が実際の手順です。

```bash
git clone https://github.com/codeql-workshops/codeql-learning-catalog
```

リポジトリのクローンしたのち、Visual Studio Codeで、このディレクトリをオープンします。

クエリを作成し始める前に、[CodeQL pack](https://codeql.github.com/docs/codeql-cli/creating-and-working-with-codeql-packs/)を作成することから始めます。CodeQL packは、クエリのまとまり、もしくは、共有するライブラリ群をまとめたものです。CodeQL packは、それらまとめたクエリを実行するための必要な情報をCodeQLに提供するために必要です。

ワークショップディレクトリへ移動して、本ワークショップを始めます。

Visual Studio Codeの中で、[integrated terminal](https://code.visualstudio.com/docs/terminal/basics)をオープンして、CodeQL packを作成するために、次のコマンドを実行します。

```bash
cd docs/QLC/100/
codeql pack init qlc-100/problems -d src
```
実行すると、`src`ディレクトリのサブディレクトリ`problems`に`qlpack.yml`ファイルが生成され、コンテンツとしてname: `qlc-100/problems`が追加されていることが分かります。

```yaml
---
library: false
name: qlc-100/problems
version: 0.0.1
```

`qlpack.yml`CodeQL packの属性情報が入ったメタデータが埋め込まれます。 属性情報の詳細は、[here](https://codeql.github.com/docs/codeql-cli/about-codeql-packs/#qlpack-yml-properties)を参照ください。 `library: false`を指定することで、libraryではない最小構成のCodeQL packとして、これから始めます。 違いは、パッケージを発行した際に判明します。発行したクエリパックは、すべての依存関係を含み、デプロイメントと評価を保証するために、事前にコンパイルされます。

もう一つ別のクエリとしてテスト用のクエリパックを作成します。作成したクエリに対して、単体テストを作成するための環境をCodeQLは提供します。この単体テストは、外部依存のないもので、異なるコンパイラ、OS,インストールされたているライブラリに対して依存性がなく、同じ結果を提供します。

```bash
codeql pack init --extractor cpp qlc-100-tests/problems -d tests
```
属性`extractor`として`cpp`を指定して、前回と同様codeQL packを作成します。`qlpack.yml`が作成されていることがわかります。通常、ターゲット言語は、databaseごと指定されます。１つのdatabaseにつき１言語となります。`extractor`に`cpp`を指定することで、テスト環境ではクエリを検証するためのテストdatabaseを作成する際に、C/C++を使用することを伝えることです。

`qlc-100/problems`CodeQL packのクエリをテストするために、クエリをどのように解決するのか`qlc-100-tests/problems`に知らせる必要があります。このために、属性`dependencies`に指定します。
以下のように、`qlpack.yml`を変更します。

```yaml
---
library: false
name: qlc-100-tests/problems
version: 0.0.1
extractor: cpp
dependencies:
  "qlc-100/problems": "*"
```

依存(dependency)は、CodeQL pack nameとversionを指定します。生成したCodeAL packはversion `0.0.1`ですが、その`qlpack.yml`では、CodeQL package managerにローカルバージョンを考慮するよう指示する意味で、`*`を指定します。これは、最新のバージョンをダウンロードするようにpackage registryへ伝える前に、ローカルのバージョンを参照します。

作成したクエリとテスト用クエリを実行することを確認するために、CodeQL CLIが名前解決できるリストを表示するコマンド`codeal pack ls`を実行します。

```bash
▶ codeql pack ls
Running on packs: qlc-100-tests/solutions, qlc-100/solutions.
Found qlc-100/solutions@0.0.1
Found qlc-100-tests/solutions@0.0.1
```

実行結果から、先ほど作成したproblem packsがリストにないことが判明とが判明しました。
The command doesn't list our just created problem packs. The
`codeql-workspace.yml` files helps the CodeQL CLI resolve CodeQL packs when
multiple are defined in a project.

`docs/QLC/100`ディレクトリの下の `codeql-workspace.yml`を開いて、以下の例のように、`"*/problems/qlpack.yml"`を最後に追加します。

```yaml
provide:
  - "*/solutions/qlpack.yml"
  - "*/problems/qlpack.yml"
```
修正したら、再度`codeql pack ls`を実行します。成功すると次のようなメッセージを見ることができます。

```bash
▶ codeql pack ls
Running on packs: qlc-100-tests/problems, qlc-100/problems, qlc-100-tests/solutions, qlc-100/solutions.
Found qlc-100/problems@0.0.1
Found qlc-100-tests/problems@0.0.1
Found qlc-100/solutions@0.0.1
Found qlc-100-tests/solutions@0.0.1
```

`provide`キーは、CodeQL packファイルのパターンを複数設定することができます。(i.e., `qlpack.yml`) CodeQL ワークスペースは、複数のCodeQL packsで構成されます。Pathパターンの書き方として、個々の指定で、1つのコンポーネントパターンとして`*`、もしくは、複数のコンポーネントマッチングを意味する`**`を指定できます。後者の`**`は、複数のカテゴリ別のCodeQL packを許可する場合、例えば言語別にCodeQL packを用意した場合に、使えるパターンです。例えば、次のようにしてした場合：

```yaml
provide:
  - "cpp/**/qlpack.yml"
  - "java/**/qlpack.yml"
```
次のディレクトリツリーで利用可能です。：

```yaml
- cpp /
  - github
    - security-queries
  qlpack.yml
    - security-tests
  qlpack.yml
    - security-libs
  qlpack.yml
- java /
  - github
    - security-queries
  qlpack.yml
    - security-tests
  qlpack.yml
    - security-libs
  qlpack.yml
```
