---
layout: workshop-overview
title: Hashconsing
course_number: LDF-204
banner: banner-code-graph-shield.png
octicon: package
toc: false
---

## Hashconsing

For the cases with variable `malloc` sizes, like `test_const_branch`, GVN identifies same-value constant accesses, but we need a special case for same-structure expression accesses. Enter `hashCons`.

From the reference: <https://codeql.github.com/docs/codeql-language-guides/hash-consing-and-value-numbering/>

> The hash consing library (defined in semmle.code.cpp.valuenumbering.HashCons) provides a mechanism for identifying expressions that have the same syntactic structure.

Additions to the imports, and use:

```java
import semmle.code.cpp.valuenumbering.HashCons
    ...
hashCons(expr)
```

This step illustrates some subtle meanings of equality. In particular, there is plain `=`, GVN, and `hashCons`:

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
```



### First 5 results
```ql file=./tests/session/Example9a/example9a.expected#L1-L5

