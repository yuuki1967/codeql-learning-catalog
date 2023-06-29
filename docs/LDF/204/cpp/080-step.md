---
layout: workshop-overview
title: Handling simple expression common to allocation and dereference
course_number: LDF-204
banner: banner-code-graph-shield.png
octicon: package
toc: false
---

## アロケーションとポインター参照との共有にハンドリング

定数を扱う例

```c++
char *buf = malloc(100);
buf[0];   // COMPLIANT
```

または

```c++
unsigned long size = 100;
char *buf = malloc(size);
buf[0];        // COMPLIANT
```

そして、静的に境界値、範囲を指定

```c++
char *buf = malloc(size);
if (size < 199)
    {
        buf[size];     // COMPLIANT
        // ...
    }
```

さらに、別の静的な指定のケースの例

1.  シンプルな表現
    
    ```c++
    char *buf = malloc(alloc_size);
    // ...
    buf[alloc_size - 1]; // COMPLIANT
    buf[alloc_size];     // NON_COMPLIANT
    ```
2.  複雑な表現
    
    ```c++
    char *buf = malloc(sz * x * y);
    buf[sz * x * y - 1]; // COMPLIANT
    ```

`e`は`Expr`,`c`は定数を使った、`malloc(e)`,`buf[e+c]'をもち、今回例として使っているクエリは、既知の境界のみをレポートするものです。

シンプルな表現をハンドルするために既存のクエリを再利用、修正してみましょう。

ポイント:

-   もう一度、メモリ確保する実装を見ると、分かる通り、それは範囲外へアクセスしています  
-   上記の特定のケースをハンドリングします。 
-   次のセッションで、この条件でクエリを作成します。




### ソリューション



```ql file=./src/session/example8.ql
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
  // Ensure buffer access refers to the matching allocation
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
  bufInit = accessInit
// +++
// Identify questionable differences
select buffer, bufferBase, bufferOffset, access, accessBase, accessOffset, bufInit, accessInit

/**
 * Extract base and offset from y = base+offset and y = base-offset.  For others, get y and 0.
 *
 * For cases like
 *     buf[alloc_size + 1];
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
```ql file=./tests/session/Example8/example8.expected#L1-L5
| test.c:16:17:16:22 | call to malloc | test.c:16:24:16:27 | size | 0 | test.c:19:5:19:17 | access to array | test.c:19:9:19:12 | size | -1 | test.c:15:19:15:22 | size | test.c:15:19:15:22 | size |
| test.c:16:17:16:22 | call to malloc | test.c:16:24:16:27 | size | 0 | test.c:21:5:21:13 | access to array | test.c:21:9:21:12 | size | 0 | test.c:15:19:15:22 | size | test.c:15:19:15:22 | size |
| test.c:28:17:28:22 | call to malloc | test.c:28:24:28:27 | size | 0 | test.c:37:5:37:17 | access to array | test.c:37:9:37:12 | size | -1 | test.c:26:19:26:22 | size | test.c:26:19:26:22 | size |
| test.c:28:17:28:22 | call to malloc | test.c:28:24:28:27 | size | 0 | test.c:39:5:39:13 | access to array | test.c:39:9:39:12 | size | 0 | test.c:26:19:26:22 | size | test.c:26:19:26:22 | size |
| test.c:28:17:28:22 | call to malloc | test.c:28:24:28:27 | size | 0 | test.c:43:9:43:17 | access to array | test.c:43:13:43:16 | size | 0 | test.c:26:19:26:22 | size | test.c:26:19:26:22 | size |
```


