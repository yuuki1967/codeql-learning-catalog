---
layout: workshop-overview
title: Include non-constant values
course_number: LDF-204
banner: banner-code-graph-shield.png
octicon: package
toc: false
---

## 変数（Include non-constant values)

前回のケースを拡張する必要があります。

```c++
void test_const_var(void)
{
    unsigned long size = 100;
    char *buf = malloc(size);
    buf[0];        // COMPLIANT
    ...
}
```

`malloc`の引数が既知の値を持つ変数になります。
前回のクエリに対して、バッファサイズ検出を削除した結果を出力しています。

### Solution

```ql file=./src/session/example3.ql
import cpp
import semmle.code.cpp.dataflow.DataFlow

// Step 3
// void test_const_var(void)
from AllocationExpr buffer, ArrayExpr access, int accessIdx, Expr allocSizeExpr
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
  // bufferSize = allocSizeExpr.getValue().toInt() and
  //
  // Ensure buffer access is to the correct allocation.
  // char *buf  = ... buf[0];
  //       ^^^  --->  ^^^
  // or
  // malloc(100);   buf[0]
  // ^^^  --------> ^^^
  //
  DataFlow::localExprFlow(buffer, access.getArrayBase())
select buffer, access, accessIdx, access.getArrayOffset()


```

### First 5 results

```ql file=./tests/session/Example3/example3.expected#L1-L5
| test.c:7:17:7:22 | call to malloc | test.c:8:5:8:10 | access to array | 0 | test.c:8:9:8:9 | 0 |
| test.c:7:17:7:22 | call to malloc | test.c:9:5:9:11 | access to array | 99 | test.c:9:9:9:10 | 99 |
| test.c:7:17:7:22 | call to malloc | test.c:10:5:10:12 | access to array | 100 | test.c:10:9:10:11 | 100 |
| test.c:16:17:16:22 | call to malloc | test.c:17:5:17:10 | access to array | 0 | test.c:17:9:17:9 | 0 |
| test.c:16:17:16:22 | call to malloc | test.c:18:5:18:11 | access to array | 99 | test.c:18:9:18:10 | 99 |

```
