---
layout: workshop-overview
title: Simple Var+Const Checks
course_number: LDF-204
banner: banner-code-graph-shield.png
octicon: package
toc: false
---

## Simple Var+Const Checks

Find problematic accesses by reverting to some *simple* `var+const` checks using `accessOffset` and `bufferOffset`.

Note:

-   These will flag some false positives.
-   The product expression `sz * x * y` is not easily checked for equality.

These are addressed in the next step.




### Solution
```ql file=./src/session/example8a.ql
```



### First 5 results
```ql file=./tests/session/example8a/example8a.expected#L1-L5



