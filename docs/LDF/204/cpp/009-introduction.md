---
layout: workshop-overview
title: Introduction
course_number: LDF-204
banner: banner-code-graph-shield.png
octicon: package
toc: false
---

## Introduction

This workshop focuses on analyzing and relating two values &#x2014; array access indices and memory allocation sizes &#x2014; in order to identify simple cases of out-of-bounds array accesses.

The following snippets demonstrate how an out-of-bounds array access can occur:

```cpp
char* buffer = malloc(10);
buffer[9] = 'a'; // ok
buffer[10] = 'b'; // out-of-bounds
```

A more complex example:

```cpp
char* buffer;
if(rand() == 1) {
    buffer = malloc(10);
}
else {
    buffer = malloc(11);
}
size_t index = 0;
if(rand() == 1) {
    index = 10;
}
buffer[index]; // potentially out-of-bounds depending on control-flow
```

Another common case *not* covered in this introductory workshop involves loops, as follows:

```cpp
int elements[5];
for (int i = 0; i <= 5; ++i) {
    elements[i] = 0;
}
```

To find these issues, we can implement an analysis that tracks the upper or lower bounds on an expression and, combined with data-flow analysis to reduce false-positives, identifies cases where the index of the array results in an access beyond the allocated size of the buffer.
