---
layout: workshop-overview
title: Interim notes
course_number: LDF-204
banner: banner-code-graph-shield.png
octicon: package
toc: false
---

## Interim notes

A common issue with the `SimpleRangeAnalysis` library is handling of cases where the bounds are undeterminable at compile-time on one or more paths. For example, even though certain paths have clearly defined bounds, the range analysis library will define the `upperBound` and `lowerBound` of `val` as `INT_MIN` and `INT_MAX` respectively:

```cpp
int val = rand() ? rand() : 30;
```

A similar case is present in the `test_const_branch` and `test_const_branch2` test-cases. In these cases, it is necessary to augment range analysis with data-flow and restrict the bounds to the upper or lower bound of computable constants that flow to a given expression. Another approach is global value numbering, used next.




