---
layout: workshop-overview
title: Global Value Numbering
course_number: LDF-204
banner: banner-code-graph-shield.png
octicon: package
toc: false
---

## Global Value Numbering

Range analyis won't bound `sz * x * y`, and simple equality checks don't work at the structure level, so switch to global value numbering.

This is the case in the last test case,

    void test_gvn_var(unsigned long x, unsigned long y, unsigned long sz)
    {
        char *buf = malloc(sz * x * y);
        buf[sz * x * y - 1]; // COMPLIANT
        buf[sz * x * y];     // NON_COMPLIANT
        buf[sz * x * y + 1]; // NON_COMPLIANT
    }

Global value numbering only knows that runtime values are equal; they are not comparable (`<, >, <=` etc.), and the *actual* value is not known.

Global value numbering finds expressions with the same known value, independent of structure.

So, we look for and use *relative* values between allocation and use.

The relevant CodeQL constructs are

```java
import semmle.code.cpp.valuenumbering.GlobalValueNumbering
...
globalValueNumber(e) = globalValueNumber(sizeExpr) and
e != sizeExpr
...
```

We can use global value numbering to identify common values as first step, but for expressions like

    buf[sz * x * y - 1]; // COMPLIANT

we have to "evaluate" the expressions &#x2013; or at least bound them.




### Solution
```ql file=./src/session/example9.ql
```



### First 5 results
```ql file=./tests/session/Example9/example9.expected#L1-L5
Results note:

-   The allocation size of 200 is never used in an access, so the GVN match eliminates it from the result list.




