---
layout: workshop-overview
title: Add Unit Conversions
course_number: LDF-204
banner: banner-code-graph-shield.png
octicon: package
toc: false
---
## 変数の不適切な型変換の分析

範囲外のアクセスのケースとして、確保したメモリサイズ変数の型変換の場合です。最終的に、範囲外のアクセスを検出するために、確保したメモリサイズと、アクセスするインデックスと比較します。

そのために、クエリに以下の実装を行います。Add these to the query:

1.  確保した単位をサイズ単位に変換
2.  アクセスする単位を、同じサイズの単位に変換

ヒント:

1. まず、配列要素のサイズを取得する必要があります。 型を取得するのに、`access.getArrayBase().getUnspecifiedType().(PointerType).getBaseType()` を使い、サイズを取得するのに`access.getArrayBase().getUnspecifiedType().(PointerType).getBaseType().getSize()`を使います。

2.  docsに記載事項がヒント: *The malloc()関数は、メモリのバイトサイズを確保し、メモリへのポインターを返す関数です*  したがって `size = 1`となります

3.  これらすべてのケースにおいて、型は`char`となります。もし、型を`int` や`double`にした場合どうなるでしょうか？




### Solution
```ql file=./src/session/example6.ql
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
select bufferSizeExpr, buffer, access, accessIdx, upperBound(accessIdx) as accessMax, bufferSize,
  access.getArrayBase().getUnspecifiedType().(PointerType).getBaseType() as arrayBaseType,
  access.getArrayBase().getUnspecifiedType().(PointerType).getBaseType().getSize() as arrayTypeSize,
  1 as allocBaseSize

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
```ql file=./tests/session/Example6/example6.expected#L1-L5
| test.c:7:24:7:26 | 100 | test.c:7:17:7:22 | call to malloc | test.c:8:5:8:10 | access to array | test.c:8:9:8:9 | 0 | 0.0 | 100 | file://:0:0:0:0 | char | 1 | 1 |
| test.c:7:24:7:26 | 100 | test.c:7:17:7:22 | call to malloc | test.c:9:5:9:11 | access to array | test.c:9:9:9:10 | 99 | 99.0 | 100 | file://:0:0:0:0 | char | 1 | 1 |
| test.c:7:24:7:26 | 100 | test.c:7:17:7:22 | call to malloc | test.c:10:5:10:12 | access to array | test.c:10:9:10:11 | 100 | 100.0 | 100 | file://:0:0:0:0 | char | 1 | 1 |
| test.c:15:26:15:28 | 100 | test.c:16:17:16:22 | call to malloc | test.c:17:5:17:10 | access to array | test.c:17:9:17:9 | 0 | 0.0 | 100 | file://:0:0:0:0 | char | 1 | 1 |
| test.c:15:26:15:28 | 100 | test.c:16:17:16:22 | call to malloc | test.c:18:5:18:11 | access to array | test.c:18:9:18:10 | 99 | 99.0 | 100 | file://:0:0:0:0 | char | 1 | 1 |
```