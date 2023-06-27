---
layout: workshop-overview
title: Cleanup and Comparison
course_number: LDF-204
banner: banner-code-graph-shield.png
octicon: package
toc: false
---
## Cleanup and Comparison

1.  Clean up the query.
2.  Compare buffer allocation size to the access index.
3.  Add expressions for `allocatedUnits` (from the malloc) and a `maxAccessedIndex` (from array accesses)
    1.  Calculate the `accessOffset` / `maxAccessedIndex` (from array accesses)
    2.  Calculate the `allocSize` / `allocatedUnits` (from the malloc)
    3.  Compare them




### Solution
```ql file=./src/session/example7.ql
```



### First 5 results
```ql file=./tests/session/Example7/example7.expected#L1-L5



