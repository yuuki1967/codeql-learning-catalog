---
layout: workshop-overview
title: Handle variables via Dataflow
course_number: LDF-204
banner: banner-code-graph-shield.png
octicon: package
toc: false
---

## DataFlowを通して変数を扱う

本ワークショップでは、アロケートした範囲外を検出することです。そのためには、クエリの中に範囲の情報を入れる必要があります。しかし、汎用化するためには、固定値ではなく、より一般的な指定が必要です。

固定値ではなく、変数をを含む`test_const_var`をresults にすることがポイントです。次の目標は、

1. 整数の固定値ではなく、確保したメモリサイズ、インデックスが変数であるケースのデータフローを検出 
cppのコードを参照すると、`malloc()`呼び出しに変数`size`を引数に入れています。

### ソリューション

```ql file=./src/session/example4.ql
import cpp
import semmle.code.cpp.dataflow.DataFlow

// Step 4
from AllocationExpr buffer, ArrayExpr access, int accessIdx, Expr allocSizeExpr, int bufferSize, Expr bse
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
  accessIdx = access.getArrayOffset().getValue().toInt() and
  //
  // malloc (100)
  //         ^^^ allocSizeExpr / bufferSize
  //
  allocSizeExpr = buffer.(Call).getArgument(0) and
  // bufferSize = allocSizeExpr.getValue().toInt() and
  //
  // unsigned long size = 100;
  // ...
  // char *buf = malloc(size);
  exists(Expr bufferSizeExpr |
    DataFlow::localExprFlow(bufferSizeExpr, buffer.getSizeExpr()) and
    bufferSizeExpr.getValue().toInt() = bufferSize
    and bse = bufferSizeExpr
  ) and
  // Ensure buffer access is to the correct allocation.
  // char *buf  = ... buf[0];
  //       ^^^  --->  ^^^
  // or
  // malloc(100);   buf[0]
  // ^^^  --------> ^^^
  //
  DataFlow::localExprFlow(buffer, access.getArrayBase())
select buffer, access, accessIdx, access.getArrayOffset(), bufferSize, bse

```

### First 5 results

```ql file=./tests/session/Example4/example4.expected#L1-L5
| test.c:7:17:7:22 | call to malloc | test.c:8:5:8:10 | access to array | 0 | test.c:8:9:8:9 | 0 | 100 | test.c:7:24:7:26 | 100 |
| test.c:7:17:7:22 | call to malloc | test.c:9:5:9:11 | access to array | 99 | test.c:9:9:9:10 | 99 | 100 | test.c:7:24:7:26 | 100 |
| test.c:7:17:7:22 | call to malloc | test.c:10:5:10:12 | access to array | 100 | test.c:10:9:10:11 | 100 | 100 | test.c:7:24:7:26 | 100 |
| test.c:16:17:16:22 | call to malloc | test.c:17:5:17:10 | access to array | 0 | test.c:17:9:17:9 | 0 | 100 | test.c:15:26:15:28 | 100 |
| test.c:16:17:16:22 | call to malloc | test.c:18:5:18:11 | access to array | 99 | test.c:18:9:18:10 | 99 | 100 | test.c:15:26:15:28 | 100 |

```
