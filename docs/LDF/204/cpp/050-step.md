---
layout: workshop-overview
title: Using SimpleRangeAnalysis
course_number: LDF-204
banner: banner-code-graph-shield.png
octicon: package
toc: false
---

## 簡易的なメモリサイズの分析

データベースに対する２ステップのクエリの実行は、不適切なサイズ、正しくない結果を生じています。データフローは、`Expr`で表す、確保したメモリサイズの範囲を常に正しく検出できるとは限りません。特に複数の定数が`Expr`へのフローになった場合に、間違う可能性があります。

サイズの範囲分析は、常に、状態の分岐を追跡します。データフロー上でguardsを使う必要ありません。つまり、ライブラリを使えば、実装する必要はないのです。

CodeQLの標準ライブラリは、本問題を追跡するために、いくつかのメカニズムを実装しています。この後ほど、`SimpleRangeAnalysis`と`GlobalValueNumbering`の２つのライブラリについて解説します。

本ワークショップのスコープ外ですが、標準の範囲分析の事例が、整数オーバフローの検出と、整数オーバフロー検証です。

それでは、`SimpleRangeAnalysis`を追加します。関連するpredicateは`upperBound`と`lowerBound`になります。これらは、バッファへのアクセス時に使います。

ポイント:

-   次のライブラリをインポート
    
        import semmle.code.cpp.rangeanalysis.SimpleRangeAnalysis

-  配列のアクセスに対して、持てる整数の範囲に対する制限を設定していない。単に利用しているだけ
    
        accessIdx = access.getArrayOffset()

-  C/C++のコードで利用している順を追跡するために以下のようにクエリに追加 
    
        select bufferSizeExpr, buffer, access, accessIdx, upperBound(accessIdx) as accessMax




### ソリューション
```ql file=./src/session/example5.ql
import cpp
import semmle.code.cpp.dataflow.DataFlow
import semmle.code.cpp.rangeanalysis.SimpleRangeAnalysis


from AllocationExpr buffer, ArrayExpr access, Expr accessIdx, int bufferSize, Expr bufferSizeExpr
where
  // malloc (100)
  // ^^^^^^^^^^^^ AllocationExpr buffer
  //
  // buf[...]
  // ^^^  ArrayExpr access
  //
  // buf[...]
  //     ^^^  int accessIdx
  //
  accessIdx = access.getArrayOffset() and
  //
  // malloc (100)
  //         ^^^ allocSizeExpr / bufferSize
  //
  getAllocConstantExpr(bufferSizeExpr, bufferSize) and
  // Ensure buffer access is to the correct allocation.
  DataFlow::localExprFlow(buffer, access.getArrayBase()) and
  // Ensure use refers to the correct size defintion, even for non-constant
  // expressions.  
  DataFlow::localExprFlow(bufferSizeExpr, buffer.getSizeExpr())
  //
select bufferSizeExpr, buffer, access, accessIdx, upperBound(accessIdx) as accessMax

/**
 * Gets an expression that flows to the allocation (which includes those already in the allocation)
 * and has a constant value.
 */
predicate getAllocConstantExpr(Expr bufferSizeExpr, int bufferSize) {
  exists(AllocationExpr buffer |
    //
    // Capture BOTH with datflow:
    // 1.
    // malloc (100)
    //         ^^^ allocSizeExpr / bufferSize
    //
    // 2.
    // unsigned long size = 100;
    // ...
    // char *buf = malloc(size);
    DataFlow::localExprFlow(bufferSizeExpr, buffer.getSizeExpr()) and
    bufferSizeExpr.getValue().toInt() = bufferSize
  )
}
```



### First 5 results
```ql file=./tests/session/Example5/example5.expected#L1-L5
| test.c:7:24:7:26 | 100 | test.c:7:17:7:22 | call to malloc | test.c:8:5:8:10 | access to array | test.c:8:9:8:9 | 0 | 0.0 |
| test.c:7:24:7:26 | 100 | test.c:7:17:7:22 | call to malloc | test.c:9:5:9:11 | access to array | test.c:9:9:9:10 | 99 | 99.0 |
| test.c:7:24:7:26 | 100 | test.c:7:17:7:22 | call to malloc | test.c:10:5:10:12 | access to array | test.c:10:9:10:11 | 100 | 100.0 |
| test.c:15:26:15:28 | 100 | test.c:16:17:16:22 | call to malloc | test.c:17:5:17:10 | access to array | test.c:17:9:17:9 | 0 | 0.0 |
| test.c:15:26:15:28 | 100 | test.c:16:17:16:22 | call to malloc | test.c:18:5:18:11 | access to array | test.c:18:9:18:10 | 99 | 99.0 |
```


