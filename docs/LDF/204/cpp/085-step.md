---
layout: workshop-overview
title: Interim notes
course_number: LDF-204
banner: banner-code-graph-shield.png
octicon: package
toc: false
---

## 補足ノート

`SimpleRangeAnalysis`ライブラリを使った共通の問題は、コンパイル時には範囲は決定できないケースをハンドリングすることです。例えば、確実なパスが定義されている場合にでさえ、範囲の分析ライブラリ`INT_MIN`,`INT_MAX`として、`val`の`upperBound`と`lowerBound`を定義します。

```cpp
int val = rand() ? rand() : 30;
```

類似のケースは、`test_const_branch`と`test_const_branch2`にあります。これらのケースにおいて、データフローとともに、引数の範囲分析、式の中で利用される値の上限、下限を制限することは必要です。別のアプローチは、次に出てくるグローバル変数の番号付けです。




