import cpp
import semmle.code.cpp.dataflow.DataFlow
import semmle.code.cpp.valuenumbering.GlobalValueNumbering
// ...
select access, gvnAllocSizeExpr, allocSizeExpr, buffer.getSizeExpr() as allocArg, gvnAccessIdx,
  accessIdx, accessOffset
