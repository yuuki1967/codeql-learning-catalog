---
layout: workshop-overview
title: Some clean-up using predicates
course_number: LDF-204
banner: banner-code-graph-shield.png
octicon: package
toc: false
---

## predicateを使ったクリーンナップ

predicate を使ったクリーンナップをいくつか紹介します。
データフローは自動で、以下の処理で、アロケートしているサイズを取り込んでいることがポイントです。

    allocSizeExpr = buffer.(Call).getArgument(0) 

`bufferSizeExpr`は冗長なので、削除しても問題ありません。

```java

allocSizeExpr = buffer.(Call).getArgument(0) and
// bufferSize = allocSizeExpr.getValue().toInt() and
//
// unsigned long size = 100;
// ...
// char *buf = malloc(size);
DataFlow::localExprFlow(bufferSizeExpr, buffer.getSizeExpr()) and

```

Also, simplify the `from...where...select`:

1. 不要な`exists`を削除します。 
2. バッファと確保したメモリサイズを取り込むために、`getValue().toInt()`とともに、`DataFlow::localExprFlow`を利用します。 




### Solution
```ql file=./src/session/example4a.ql
import cpp
import semmle.code.cpp.dataflow.DataFlow

from AllocationExpr buffer, ArrayExpr access, int accessIdx, int bufferSize, Expr bufferSizeExpr
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
  getAllocConstantExpr(bufferSizeExpr, bufferSize) and
  // Ensure buffer access refers to the matching allocation
  // ensureSameFunction(buffer, access.getArrayBase()) and
  DataFlow::localExprFlow(buffer, access.getArrayBase()) and
  // Ensure buffer access refers to the matching allocation
  // ensureSameFunction(bufferSizeExpr, buffer.getSizeExpr()) and
  DataFlow::localExprFlow(bufferSizeExpr, buffer.getSizeExpr()) 
  //
select buffer, access, accessIdx, access.getArrayOffset(), bufferSize, bufferSizeExpr

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
```ql file=./tests/session/Example4a/example4a.expected#L1-L5
| test.c:7:17:7:22 | call to malloc | test.c:8:5:8:10 | access to array | 0 | test.c:8:9:8:9 | 0 | 100 | test.c:7:24:7:26 | 100 |
| test.c:7:17:7:22 | call to malloc | test.c:9:5:9:11 | access to array | 99 | test.c:9:9:9:10 | 99 | 100 | test.c:7:24:7:26 | 100 |
| test.c:7:17:7:22 | call to malloc | test.c:10:5:10:12 | access to array | 100 | test.c:10:9:10:11 | 100 | 100 | test.c:7:24:7:26 | 100 |
| test.c:16:17:16:22 | call to malloc | test.c:17:5:17:10 | access to array | 0 | test.c:17:9:17:9 | 0 | 100 | test.c:15:26:15:28 | 100 |
| test.c:16:17:16:22 | call to malloc | test.c:18:5:18:11 | access to array | 99 | test.c:18:9:18:10 | 99 | 100 | test.c:15:26:15:28 | 100 |

```