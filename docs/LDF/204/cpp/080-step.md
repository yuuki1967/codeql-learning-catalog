---
layout: workshop-overview
title: Handling simple expression common to allocation and dereference
course_number: LDF-204
banner: banner-code-graph-shield.png
octicon: package
toc: false
---

## Handling simple expression common to allocation and dereference

Up to now, we have dealt with constant values

```c++
char *buf = malloc(100);
buf[0];   // COMPLIANT
```

or

```c++
unsigned long size = 100;
char *buf = malloc(size);
buf[0];        // COMPLIANT
```

and statically determinable or boundable values

```c++
char *buf = malloc(size);
if (size < 199)
    {
        buf[size];     // COMPLIANT
        // ...
    }
```

There is another statically determinable case. Examples are

1.  A simple expression
    
    ```c++
    char *buf = malloc(alloc_size);
    // ...
    buf[alloc_size - 1]; // COMPLIANT
    buf[alloc_size];     // NON_COMPLIANT
    ```
2.  A complex expression
    
    ```c++
    char *buf = malloc(sz * x * y);
    buf[sz * x * y - 1]; // COMPLIANT
    ```

These both have the form `malloc(e)`, `buf[e+c]`, where `e` is an `Expr` and `c` is a constant, possibly 0. Our existing queries only report known or boundable results, but here `e` is neither.

Write a new query, re-using or modifying the existing one to handle the simple expression (case 1).

Note:

-   We are looking at the allocation expression again, not its possible value.
-   This only handles very specific cases. Constructing counterexamples is easy.
-   We will address this in the next section.




### Solution



```ql file=./src/session/example8.ql
```
### First 5 results
```ql file=./tests/session/Example8/example8.expected#L1-L5



