---
layout: workshop-overview
title: Identify Syntactic Elements
course_number: LDF-204
banner: banner-code-graph-shield.png
octicon: package
toc: false
---

## 文節(Syntactic-宣言、式、命令など)要素の認識

まず最初のステップ:

1.  動的メモリ確保の関数`malloc`の検出し、
2.  確保されたバッファへのアクセスを検出。 本ワークショップでは、バッファへのアクセスは、配列へのアクセスのみを想定しています。ポインターを使った参照はカバーしていません。

本ワークショップのゴールは、配列へのアクセス、配列、バッファのサイズ、バッファのオフセットを見つけることです。

The focus here is on

    void test_const(void)

and

    void test_const_var(void)

in [db.c](file:///session-db/DB/db.c).




### ヒント

1.  `Expr::getValue()::toInt()` can be used to get the integer value of a constant expression.




### ソリューション
```ql file=./src/session/example1.ql
```



### 結果 5 
```ql file=./tests/session/Example1/example1.expected#L1-L5



