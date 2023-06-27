---
layout: workshop-overview
title: Identify Syntactic Elements
course_number: LDF-204
banner: banner-code-graph-shield.png
octicon: package
toc: false
---

## Identify Syntactic Elements

In the first step we are going to

1.  identify a dynamic allocation with `malloc` and
2.  an access to that allocated buffer. The access is via an array expression; we are **not** going to cover pointer dereferencing.

The goal of this exercise is to then output the array access, array size, buffer, and buffer offset.

The focus here is on

    void test_const(void)

and

    void test_const_var(void)

in [db.c](file:///Users/hohn/local/codeql-workshop-runtime-values-c/session-db/DB/db.c).




### Hints

1.  `Expr::getValue()::toInt()` can be used to get the integer value of a constant expression.




### Solution
```ql file=./src/session/example1.ql
```



### First 5 results
```ql file=./tests/session/Example1/example1.expected#L1-L5



