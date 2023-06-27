import cpp
import semmle.code.cpp.dataflow.DataFlow

// ...
select buffer, access, accessIdx, access.getArrayOffset(), bufferSize, allocSizeExpr
