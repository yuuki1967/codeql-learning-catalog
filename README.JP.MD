# <img src="https://cloud.githubusercontent.com/assets/98681/24211275/c4ebd04e-0ee8-11e7-8606-061d656a42df.png" width="64" height="64"><br>CodeQL Learning Catalog

[Browse The Catalog](https://codeql-learning-catalog.github.com)
&nbsp;•&nbsp;
[Open an issue](../../issues)

<br>

CodeQLラーニングカタログは、CodeQLを学習していただくためのハンズオンを含んだコンテンツとなります。

# How to Use The Catalog

次の２つの環境でご利用いただけます。
- Codespaces
  <img src="public/assets/images/CodeQL-learning-Catalgo-CodeSpacesConf.png">
- ローカルPC
  git cloneコマンドで、本リポジトリをローカルにクローン

## ディレクトリ構成  

ディレクトリ構成について説明します。ワークショップは、すべて`docs`ディレクトリは以下になります。
その下に２つのワークショップがあります。１つは言語に依存しないワークショップ、もう１つは言語依存のワークショップとなります。言語依存のワークショップは現在C++,pythonの２つになります。

### 言語非依存のワークショップ 

言語 *非依存* ワークショップは言語*依存*とは異なり、１種類のみのワークショップです。
<img src="public/assets/images/language-independent-structure.png">


### 言語依存のワークショップ 

言語*依存*のワークショップは、言語ごとのワークショップになっております。例えば、`cpp`は１つのワークショップ、`python`は別ワークショップとなります。
<img src="public/assets/images/language-dependent-structure.png">

### index.mdファイルのメタデータ

それぞれのワークショップのディレクトリには、`index.md`ファイルがあります。その中に以下のメタデータがあります。
course_numberの見方は、<ワークショップタイトル>-<レベル>となっています。
|ワークショップタイトル|説明 |
|------------------|--- |
|QLC|CodeQL Core|
|LDF|Language Dependent Features|
|TIP|Tooling,Infrastructure,and Practice|
|EXP|Explorations|

|レベル|説明|
|-----|---|
|10x|基本レベル|
|20x|中級レベル|
|30x|アドバンスドレベル|

```
---
layout: workshop-index
title: Elements of Syntactical Program Analysis I for Python
course_number: LDF-101-PY
abstract: Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Blandit volutpat maecenas volutpat blandit. Ut morbi tincidunt augue interdum. Cursus eget nunc scelerisque viverra. Et tortor consequat id porta nibh venenatis cras sed felis. Ante metus dictum at tempor commodo ullamcorper. Aliquam purus sit amet luctus venenatis lectus magna. 
language: python
feedback: https://www.feedback.com 
banner: banner-code-graph-shield.png
video: url-to-your-video
deck: url-to-your-deck 
octicon: package
toc: false
---
## Previewing Your Work


To preview your work, at a command prompt type:

```
script/server 
```

From the root of this repository. 

## Inserting Code Blocks

To prevent examples that do not run from being used in workshops, this system
provides a way to ensure your examples are runnable. 

Any time you have a `ql` example, you must provide a unit test and a source file
for the `ql`. To insert that code into your workshop you may use custom
directives. 

**To insert an entire file**

<pre>
```ql file=./src/myfile.ql
```
</pre>

**To insert a portion of a file**

<pre>
```ql file=./src/solutions/PuzzleOneAttemptTwoB.ql#L1-L17
```
</pre>

## Making Your Content Findable

To increase relevancy of results, the workshop catalog does not perform full
text indexing. Search results are based on two factors: 1) title and 2) topics.
You may influence the search relevancy by either altering your title or adding a
`topics` metadata tag to the frontmatter of any page. For example:

```
---
layout: workshop-index
title: Elements of Syntactical Program Analysis I for C/C++
topics: dataflow, taint
toc: false
---
```