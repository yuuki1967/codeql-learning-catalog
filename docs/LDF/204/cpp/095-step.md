---
layout: workshop-overview
title: Hashconsing
course_number: LDF-204
banner: banner-code-graph-shield.png
octicon: package
toc: false
---

## Hashconsing

`malloc`の確保するサイズが`test_const_branch`のような変数の場合、Golobal Values Numbering(GVN)は、同じ定数でアクセスすると認識します。しかし、同じ構造の式を使ったアクセスに関して、特別なケースを必要とします。CodeQLでは、`hascons`モジュールを実装しています。

<https://codeql.github.com/docs/codeql-language-guides/hash-consing-and-value-numbering/>を参照してください。

> The hash consing library (defined in semmle.code.cpp.valuenumbering.HashCons) provides a mechanism for identifying expressions that have the same syntactic structure.

利用方法については、以下のようにライブラリをインポートします。:
```java
import semmle.code.cpp.valuenumbering.HashCons
    ...
hashCons(expr)
```

このステップは、等価の微妙な意味を表現します。特に`=`, Global Values Numbering(GVN),`hashCons`についてです。

```java
// 0 results:
// (accessBase = allocSizeExpr or accessBase = allocArg)

// Only 6 results:

// (
//   gvnAccessIdx = gvnAllocSizeExpr or
//   gvnAccessIdx = globalValueNumber(allocArg)
// )

// 9 results:
(
  hashCons(accessBase) = hashCons(allocSizeExpr) or
  hashCons(accessBase) = hashCons(allocArg)
)

```




### Solution
```ql file=./src/session/Example9a.ql
import cpp
import semmle.code.cpp.dataflow.DataFlow
import semmle.code.cpp.valuenumbering.GlobalValueNumbering
import semmle.code.cpp.valuenumbering.HashCons

from
  AllocationExpr buffer, ArrayExpr access, Expr allocSizeExpr, Expr accessIdx, GVN gvnAccessIdx,
  GVN gvnAllocSizeExpr, int accessOffset,
  // +++
  Expr allocArg, Expr accessBase
where
  // malloc (100)
  // ^^^^^^^^^^^^ AllocationExpr buffer
  // buf[...]
  // ^^^  ArrayExpr access
  // buf[...]
  //     ^^^ accessIdx
  accessIdx = access.getArrayOffset() and
  // Find allocation size expression flowing to the allocation.
  DataFlow::localExprFlow(allocSizeExpr, buffer.getSizeExpr()) and
  // Ensure buffer access refers to the matching allocation
  DataFlow::localExprFlow(buffer, access.getArrayBase()) and
  // Use GVN
  globalValueNumber(accessIdx) = gvnAccessIdx and
  globalValueNumber(allocSizeExpr) = gvnAllocSizeExpr and
  (
    // buf[size] or buf[100]
    gvnAccessIdx = gvnAllocSizeExpr and
    accessOffset = 0 and
    // +++
    accessBase = accessIdx
    or
    // buf[sz * x * y + 1];
    exists(AddExpr add |
      accessIdx = add and
      accessOffset >= 0 and
      accessOffset = add.getRightOperand().(Literal).getValue().toInt() and
      globalValueNumber(add.getLeftOperand()) = gvnAllocSizeExpr and
      // +++
      accessBase = add.getLeftOperand()
    )
  ) and
  buffer.getSizeExpr() = allocArg and
  (
    accessOffset >= 0 and
    // +++
    // Illustrating the subtle meanings of equality:    
    // 0 results:
    // (accessBase = allocSizeExpr or accessBase = allocArg)
    // Only 6 results:
    // (
    //   gvnAccessIdx = gvnAllocSizeExpr or
    //   gvnAccessIdx = globalValueNumber(allocArg)
    // )
    // 9 results:
    (
      hashCons(accessBase) = hashCons(allocSizeExpr) or
      hashCons(accessBase) = hashCons(allocArg)
    )
  )
// gvnAccessIdx = globalValueNumber(allocArg))
// +++ overview select:
select access, gvnAllocSizeExpr, allocSizeExpr, allocArg, gvnAccessIdx, accessIdx, accessBase,
  accessOffset
```



### First 5 results
```ql file=./tests/session/Example9a/example9a.expected#L1-L5
| test.c:21:5:21:13 | access to array | test.c:15:26:15:28 | GVN | test.c:15:26:15:28 | 100 | test.c:16:24:16:27 | size | test.c:15:26:15:28 | GVN | test.c:21:9:21:12 | size | test.c:21:9:21:12 | size | 0 |
| test.c:21:5:21:13 | access to array | test.c:15:26:15:28 | GVN | test.c:16:24:16:27 | size | test.c:16:24:16:27 | size | test.c:15:26:15:28 | GVN | test.c:21:9:21:12 | size | test.c:21:9:21:12 | size | 0 |
| test.c:38:5:38:12 | access to array | test.c:26:39:26:41 | GVN | test.c:26:39:26:41 | 100 | test.c:28:24:28:27 | size | test.c:26:39:26:41 | GVN | test.c:38:9:38:11 | 100 | test.c:38:9:38:11 | 100 | 0 |
| test.c:69:5:69:19 | access to array | test.c:63:24:63:33 | GVN | test.c:63:24:63:33 | alloc_size | test.c:63:24:63:33 | alloc_size | test.c:63:24:63:33 | GVN | test.c:69:9:69:18 | alloc_size | test.c:69:9:69:18 | alloc_size | 0 |
| test.c:73:9:73:23 | access to array | test.c:63:24:63:33 | GVN | test.c:63:24:63:33 | alloc_size | test.c:63:24:63:33 | alloc_size | test.c:63:24:63:33 | GVN | test.c:73:13:73:22 | alloc_size | test.c:73:13:73:22 | alloc_size | 0 |
```
