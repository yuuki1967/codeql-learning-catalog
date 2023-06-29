---
layout: workshop-overview
title: Connect Allocation(s) with Access(es)
course_number: LDF-204
banner: banner-code-graph-shield.png
octicon: package
toc: false
---

## アクセスを伴うアロケーションへの接続

前回のクエリは、配列のアクセスを伴う、`malloc`呼び出しの接続をフェールするものです。ある関数からの`malloc`は、別の関数ので中で、アクセスする。

これらのケースを捕まえるために、前回の演習からのクエリを使い、

1.  メモリアロケーションへの接続、
2.  その配列へアクセス

### ヒント

1. 配列とバッファとの関連付のために`DataFlow::localExprFlow()`を使います  
2. 配列名は、`buf[0]`の`buf`です。predicate `Expr.getArrayBase()`を使って検出します




### Solution
```ql file=./src/session/example2.ql
import cpp
import semmle.code.cpp.dataflow.DataFlow

// Step 2
// void test_const(void)
// void test_const_var(void)
from AllocationExpr buffer, ArrayExpr access, int bufferSize, int accessIdx, Expr allocSizeExpr
where
  // malloc (100)
  // ^^^^^^  AllocationExpr buffer
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
  bufferSize = allocSizeExpr.getValue().toInt() and
  //
  // Ensure buffer access is to the correct allocation.
  // char *buf  = ... buf[0];
  //       ^^^  --->  ^^^
  // or
  // malloc(100);   buf[0]
  // ^^^  --------> ^^^
  //
  DataFlow::localExprFlow(buffer, access.getArrayBase())
select buffer, access, accessIdx, access.getArrayOffset(), bufferSize, allocSizeExpr

```



### First 5 results
```ql file=./tests/session/Example2/example2.expected#L1-L5
| test.c:7:17:7:22 | call to malloc | test.c:8:5:8:10 | access to array | 0 | test.c:8:9:8:9 | 0 | 100 | test.c:7:24:7:26 | 100 |
| test.c:7:17:7:22 | call to malloc | test.c:9:5:9:11 | access to array | 99 | test.c:9:9:9:10 | 99 | 100 | test.c:7:24:7:26 | 100 |
| test.c:7:17:7:22 | call to malloc | test.c:10:5:10:12 | access to array | 100 | test.c:10:9:10:11 | 100 | 100 | test.c:7:24:7:26 | 100 |

```


