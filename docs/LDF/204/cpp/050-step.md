---
layout: workshop-overview
title: Using SimpleRangeAnalysis
course_number: LDF-204
banner: banner-code-graph-shield.png
octicon: package
toc: false
---

## SimpleRangeAnalysis

Running the query from Step 2 against the database yields a significant number of missing or incorrect results. The reason is that although great at identifying compile-time constants and their use, data-flow analysis is not always the right tool for identifying the *range* of values an `Expr` might have, particularly when multiple potential constants might flow to an `Expr`.

The range analysis already handles conditional branches; we don't have to use guards on data flow &#x2013; don't implement your own interpreter if you can use the library.

The CodeQL standard library has several mechanisms for addressing this problem; in the remainder of this workshop we will explore two of them: `SimpleRangeAnalysis` and, later, `GlobalValueNumbering`.

Although not in the scope of this workshop, a standard use-case for range analysis is reliably identifying integer overflow and validating integer overflow checks.

Now, add the use of the `SimpleRangeAnalysis` library. Specifically, the relevant library predicates are `upperBound` and `lowerBound`, to be used with the buffer access argument.

Notes:

-   This requires the import
    
        import semmle.code.cpp.rangeanalysis.SimpleRangeAnalysis
-   We are not limiting the array access to integers any longer. Thus, we just use
    
        accessIdx = access.getArrayOffset()
-   To see the results in the order used in the C code, use
    
        select bufferSizeExpr, buffer, access, accessIdx, upperBound(accessIdx) as accessMax




### Solution
```ql file=./src/session/example5.ql
```



### First 5 results
```ql file=./tests/session/Example5/example5.expected#L1-L5



