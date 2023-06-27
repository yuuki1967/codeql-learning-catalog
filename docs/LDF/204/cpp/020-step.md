---
layout: workshop-overview
title: Connect Allocation(s) with Access(es)
course_number: LDF-204
banner: banner-code-graph-shield.png
octicon: package
toc: false
---

## Connect Allocation(s) with Access(es)

The previous query fails to connect the `malloc` calls with the array accesses, and in the results, `mallocs` from one function are paired with accesses in another.

To address these, take the query from the previous exercise and

1.  connect the allocation(s) with the
2.  array accesses

### Hints

1.  Use `DataFlow::localExprFlow()` to relate the allocated buffer to the array base.
2.  The the array base is the `buf` part of `buf[0]`. Use the `Expr.getArrayBase()` predicate.




### Solution
```ql file=./src/session/example2.ql
```



### First 5 results
```ql file=./tests/session/Example2/example2.expected#L1-L5



