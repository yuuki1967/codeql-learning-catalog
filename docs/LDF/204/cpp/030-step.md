---
layout: workshop-overview
title: Include non-constant values
course_number: LDF-204
banner: banner-code-graph-shield.png
octicon: package
toc: false
---

## Include non-constant values

The previous results need to be extended to the case

```c++
void test_const_var(void)
{
    unsigned long size = 100;
    char *buf = malloc(size);
    buf[0];        // COMPLIANT
    ...
}
```

Here, the `malloc` argument is a variable with known value.

We include this result by removing the size-retrieval from the prior query.

### Solution

```ql file=./src/session/example3.ql

```

### First 5 results

```ql file=./tests/session/Example3/example3.expected#L1-L5

```
