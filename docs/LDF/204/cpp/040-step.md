---
layout: workshop-overview
title: Handle variables via Dataflow
course_number: LDF-204
banner: banner-code-graph-shield.png
octicon: package
toc: false
---

## Handle variables via Dataflow

We are looking for out-of-bounds accesses, so we to need to include the bounds. But in a more general way than looking only at constant values.

Note the results for the cases in `test_const_var` which involve a variable access rather than a constant. The next goal is

1.  to handle the case where the allocation size or array index are variables (with constant values) rather than integer constants.

We have an expression `size` that flows into the `malloc()` call.

### Solution

```ql file=./src/session/example4.ql

```

### First 5 results

```ql file=./tests/session/Example4/example4.expected#L1-L5



```
