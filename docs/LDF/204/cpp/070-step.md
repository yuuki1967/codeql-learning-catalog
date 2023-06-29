---
layout: workshop-overview
title: Cleanup and Comparison
course_number: LDF-204
banner: banner-code-graph-shield.png
octicon: package
toc: false
---
## クリーンナップと比較

1.  クエリをクリーンナップ
2.  アクセスするインデックスと確保したバッファサイズとの比較を行う
3.  `allocatedUnits` (from the malloc) と`maxAccessedIndex` (from array accesses)を以下のように追加
    1.  `accessOffset` / `maxAccessedIndex` (from array accesses)の除算
    2.  `allocSize` / `allocatedUnits` (from the malloc)の除算
    3.  上記の値を比較




### ソリューション
```ql file=./src/session/example7.ql
import cpp
import semmle.code.cpp.dataflow.DataFlow
import semmle.code.cpp.rangeanalysis.SimpleRangeAnalysis

from
  AllocationExpr buffer, ArrayExpr access, Expr accessIdx, int bufferSize, Expr bufferSizeExpr,
  int arrayTypeSize, int allocBaseSize
where
  // malloc (100)
  // ^^^^^^^^^^^^ AllocationExpr buffer
  // buf[...]
  // ^^^  ArrayExpr access
  // buf[...]
  //     ^^^  int accessIdx
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
  DataFlow::localExprFlow(bufferSizeExpr, buffer.getSizeExpr()) and 
  //
  arrayTypeSize = access.getArrayBase().getUnspecifiedType().(PointerType).getBaseType().getSize() and
  1 = allocBaseSize
//
select bufferSizeExpr, buffer, access, accessIdx, upperBound(accessIdx) as accessMax, bufferSize,
  access.getArrayBase().getUnspecifiedType().(PointerType).getBaseType() as arrayBaseType,
  allocBaseSize * bufferSize as allocatedUnits, arrayTypeSize * accessMax as maxAccessedIndex

/**
 * Gets an expression that flows to the allocation (which includes those already in the allocation)
 * and has a constant value.
 */
predicate getAllocConstantExpr(Expr bufferSizeExpr, int bufferSize) {
  exists(AllocationExpr buffer |
    // Capture BOTH with datflow:
    // 1.
    // malloc (100)
    //         ^^^ allocSizeExpr / bufferSize
    // 2.
    // unsigned long size = 100; ... ; char *buf = malloc(size);
    DataFlow::localExprFlow(bufferSizeExpr, buffer.getSizeExpr()) and
    bufferSizeExpr.getValue().toInt() = bufferSize
  )
}
```



### First 5 results
```ql file=./tests/session/Example7/example7.expected#L1-L5
| test.c:7:24:7:26 | 100 | test.c:7:17:7:22 | call to malloc | test.c:8:5:8:10 | access to array | test.c:8:9:8:9 | 0 | 0.0 | 100 | file://:0:0:0:0 | char | 100 | 0.0 |
| test.c:7:24:7:26 | 100 | test.c:7:17:7:22 | call to malloc | test.c:9:5:9:11 | access to array | test.c:9:9:9:10 | 99 | 99.0 | 100 | file://:0:0:0:0 | char | 100 | 99.0 |
| test.c:7:24:7:26 | 100 | test.c:7:17:7:22 | call to malloc | test.c:10:5:10:12 | access to array | test.c:10:9:10:11 | 100 | 100.0 | 100 | file://:0:0:0:0 | char | 100 | 100.0 |
| test.c:15:26:15:28 | 100 | test.c:16:17:16:22 | call to malloc | test.c:17:5:17:10 | access to array | test.c:17:9:17:9 | 0 | 0.0 | 100 | file://:0:0:0:0 | char | 100 | 0.0 |
| test.c:15:26:15:28 | 100 | test.c:16:17:16:22 | call to malloc | test.c:18:5:18:11 | access to array | test.c:18:9:18:10 | 99 | 99.0 | 100 | file://:0:0:0:0 | char | 100 | 99.0 |
```


