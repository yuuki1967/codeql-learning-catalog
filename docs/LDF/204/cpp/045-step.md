---
layout: workshop-overview
title: Some clean-up using predicates
course_number: LDF-204
banner: banner-code-graph-shield.png
octicon: package
toc: false
---

## Some clean-up using predicates

Some clean-up using predicates

Note that the dataflow automatically captures/includes the

    allocSizeExpr = buffer.(Call).getArgument(0) 

so that's now redundant with `bufferSizeExpr` and can be removed.

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

1.  Remove unnecessary `exists` clauses.
2.  Use `DataFlow::localExprFlow` for the buffer and allocation sizes, with `getValue().toInt()` as one possibility (one predicate).




### Solution
```ql file=./src/session/example4a.ql
```



### First 5 results
```ql file=./tests/session/Example4a/example4a.expected#L1-L5



