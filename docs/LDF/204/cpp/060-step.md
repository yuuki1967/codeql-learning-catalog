---
layout: workshop-overview
title: Add Unit Conversions
course_number: LDF-204
banner: banner-code-graph-shield.png
octicon: package
toc: false
---
## Add Unit Conversions

To finally determine (some) out-of-bounds accesses, we have to convert allocation units (usually in bytes) to size units. Then we are finally in a position to compare buffer allocation size to the access index to find out-of-bounds accesses &#x2013; at least for expressions with known values.

Add these to the query:

1.  Convert allocation units to size units.
2.  Convert access units to the same size units.

Hints:

1.  We need the size of the array element. Use `access.getArrayBase().getUnspecifiedType().(PointerType).getBaseType()` to see the type and `access.getArrayBase().getUnspecifiedType().(PointerType).getBaseType().getSize()` to get its size.

2.  Note from the docs: *The malloc() function allocates size bytes of memory and returns a pointer to the allocated memory.* So `size = 1`

3.  These test cases all use type `char`. What would happen for `int` or `double`?




### Solution
```ql file=./src/session/example6.ql
```



### First 5 results
```ql file=./tests/session/Example6/example6.expected#L1-L5



