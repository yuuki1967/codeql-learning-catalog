---
layout: workshop-overview
title: Global Value Numbering
course_number: LDF-204
banner: banner-code-graph-shield.png
octicon: package
toc: false
---

## Global Value Numbering(グローバル値の番号付)

範囲分析は、`sz * x * y`については、作用しない、単純な品質チェックにおいても、構造化レベルで作用しない。そのため、グローバル値の番号付に切り替えたほうが良いです。

これが、サンプルのケースです。

    void test_gvn_var(unsigned long x, unsigned long y, unsigned long sz)
    {
        char *buf = malloc(sz * x * y);
        buf[sz * x * y - 1]; // COMPLIANT
        buf[sz * x * y];     // NON_COMPLIANT
        buf[sz * x * y + 1]; // NON_COMPLIANT
    }

グローバル値は、実行時の値が等しいことのみ判断できるが、比較(`<, >, <=` etc.)や、*実際の*値は判定できません。
グローバル値番号付は、同じ既存の値を使った式を検出し、構造体とは独立しています。

そのため、アロケーションと利用の間での*関係のある*値を探して、利用します。

関係するCodeQLの構造は次のようになります

```java
import semmle.code.cpp.valuenumbering.GlobalValueNumbering
...
globalValueNumber(e) = globalValueNumber(sizeExpr) and
e != sizeExpr
...
```
最初のステップで、共有の値を見つけるためにグローバル値の番号付を利用します。次のような表現になります

    buf[sz * x * y - 1]; // COMPLIANT

このコーデングを"評価" &#x2013;　少なくとも、それらの境界を示す必要があります。




### ソリューション
```ql file=./src/session/example9.ql
import cpp
import semmle.code.cpp.dataflow.DataFlow
import semmle.code.cpp.valuenumbering.GlobalValueNumbering

from
  AllocationExpr buffer, ArrayExpr access,
  // ---
  // Expr bufferSizeExpr
  // int accessOffset, Expr accessBase, Expr bufferBase, int bufferOffset, Variable bufInit,
  // +++
  Expr allocSizeExpr, Expr accessIdx, GVN gvnAccessIdx, GVN gvnAllocSizeExpr, int accessOffset
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
    accessOffset = 0
    or
    // buf[sz * x * y + 1];
    exists(AddExpr add |
      accessIdx = add and
      accessOffset >= 0 and
      accessOffset = add.getRightOperand().(Literal).getValue().toInt() and
      globalValueNumber(add.getLeftOperand()) = gvnAllocSizeExpr
    )
  )
select access, gvnAllocSizeExpr, allocSizeExpr, buffer.getSizeExpr() as allocArg, gvnAccessIdx,
  accessIdx, accessOffset
```



### First 5 results
```ql file=./tests/session/Example9/example9.expected#L1-L5
| test.c:21:5:21:13 | access to array | test.c:15:26:15:28 | GVN | test.c:15:26:15:28 | 100 | test.c:16:24:16:27 | size | test.c:15:26:15:28 | GVN | test.c:21:9:21:12 | size | 0 |
| test.c:21:5:21:13 | access to array | test.c:15:26:15:28 | GVN | test.c:16:24:16:27 | size | test.c:16:24:16:27 | size | test.c:15:26:15:28 | GVN | test.c:21:9:21:12 | size | 0 |
| test.c:38:5:38:12 | access to array | test.c:26:39:26:41 | GVN | test.c:26:39:26:41 | 100 | test.c:28:24:28:27 | size | test.c:26:39:26:41 | GVN | test.c:38:9:38:11 | 100 | 0 |
| test.c:69:5:69:19 | access to array | test.c:63:24:63:33 | GVN | test.c:63:24:63:33 | alloc_size | test.c:63:24:63:33 | alloc_size | test.c:63:24:63:33 | GVN | test.c:69:9:69:18 | alloc_size | 0 |
| test.c:73:9:73:23 | access to array | test.c:63:24:63:33 | GVN | test.c:63:24:63:33 | alloc_size | test.c:63:24:63:33 | alloc_size | test.c:63:24:63:33 | GVN | test.c:73:13:73:22 | alloc_size | 0 |
```

結果ノート:

-  200のアロケーションサイズは、アクセスされることはない。その結果、結果のリストからGlobal Values Numberingを除外する。
