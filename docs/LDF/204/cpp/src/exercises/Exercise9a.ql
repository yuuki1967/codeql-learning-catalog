import cpp
import semmle.code.cpp.dataflow.DataFlow
import semmle.code.cpp.valuenumbering.GlobalValueNumbering
import semmle.code.cpp.valuenumbering.HashCons
// ...
select access, gvnAllocSizeExpr, allocSizeExpr, allocArg, gvnAccessIdx, accessIdx, accessBase,
  accessOffset
