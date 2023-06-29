---
layout: workshop-overview
title: Simple Var+Const Checks
course_number: LDF-204
banner: banner-code-graph-shield.png
octicon: package
toc: false
---

## シンプルな変数+定数のチェック

`accessOffset`と`bufferOffset`を使って、いくつかの*シンプル*な、`var+const`チェックに立ち返ることで、問題のあるアクセスを見つけます。

ポイント:

-   これらは、いくつかの誤検知が発見されます
-   式`sz * x * y`は容易に、品質チェックされません 

次のステップで、この問題について実施していきます。



### Solution
```ql file=./src/session/example8a.ql
import cpp
import semmle.code.cpp.dataflow.DataFlow
import semmle.code.cpp.rangeanalysis.SimpleRangeAnalysis

from
  AllocationExpr buffer, ArrayExpr access, Expr bufferSizeExpr,
  // ---
  // int maxAccessedIndex, int allocatedUnits,
  // int bufferSize
  int accessOffset, Expr accessBase, Expr bufferBase, int bufferOffset, Variable bufInit,
  Variable accessInit
where
  // malloc (...)
  // ^^^^^^^^^^^^ AllocationExpr buffer
  // ---
  // getAllocConstExpr(...)
  // +++
  bufferSizeExpr = buffer.getSizeExpr() and
  // Ensure buffer access refers to the matching allocation
  DataFlow::localExprFlow(buffer, access.getArrayBase()) and
  // Find allocation size expression flowing to buffer.
  DataFlow::localExprFlow(bufferSizeExpr, buffer.getSizeExpr()) and
  //
  // +++
  // base+offset
  extractBaseAndOffset(bufferSizeExpr, bufferBase, bufferOffset) and
  extractBaseAndOffset(access.getArrayOffset(), accessBase, accessOffset) and
  // +++
  // Same initializer variable
  bufferBase.(VariableAccess).getTarget() = bufInit and
  accessBase.(VariableAccess).getTarget() = accessInit and
  bufInit = accessInit and
  // +++
  // Identify questionable differences
  accessOffset >= bufferOffset
select buffer, bufferBase, access, accessBase, bufInit, bufferOffset, accessInit, accessOffset

/**
 * Extract base and offset from y = base+offset and y = base-offset.  For others, get y and 0.
 *
 * For cases like
 *     buf[alloc_size + 1];
 *         ^^^^^^^^^^^^^^ expr
 *         ^^^^^^^^^^ base
 *                    ^^^ offset
 *
 * The more general
 *     buf[sz * x * y - 1];
 * requires other tools.
 */
bindingset[expr]
predicate extractBaseAndOffset(Expr expr, Expr base, int offset) {
  offset = expr.(AddExpr).getRightOperand().getValue().toInt() and
  base = expr.(AddExpr).getLeftOperand()
  or
  offset = -expr.(SubExpr).getRightOperand().getValue().toInt() and
  base = expr.(SubExpr).getLeftOperand()
  or
  not expr instanceof AddExpr and
  not expr instanceof SubExpr and
  base = expr and
  offset = 0
}
```



### First 5 results
```ql file=./tests/session/example8a/example8a.expected#L1-L5
| test.c:16:17:16:22 | call to malloc | test.c:16:24:16:27 | size | test.c:21:5:21:13 | access to array | test.c:21:9:21:12 | size | test.c:15:19:15:22 | size | 0 | test.c:15:19:15:22 | size | 0 |
| test.c:28:17:28:22 | call to malloc | test.c:28:24:28:27 | size | test.c:39:5:39:13 | access to array | test.c:39:9:39:12 | size | test.c:26:19:26:22 | size | 0 | test.c:26:19:26:22 | size | 0 |
| test.c:28:17:28:22 | call to malloc | test.c:28:24:28:27 | size | test.c:43:9:43:17 | access to array | test.c:43:13:43:16 | size | test.c:26:19:26:22 | size | 0 | test.c:26:19:26:22 | size | 0 |
| test.c:28:17:28:22 | call to malloc | test.c:28:24:28:27 | size | test.c:44:9:44:21 | access to array | test.c:44:13:44:16 | size | test.c:26:19:26:22 | size | 0 | test.c:26:19:26:22 | size | 1 |
| test.c:28:17:28:22 | call to malloc | test.c:28:24:28:27 | size | test.c:45:9:45:21 | access to array | test.c:45:13:45:16 | size | test.c:26:19:26:22 | size | 0 | test.c:26:19:26:22 | size | 2 |
```

