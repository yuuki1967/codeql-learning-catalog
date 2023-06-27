import cpp
import semmle.code.cpp.dataflow.DataFlow
import semmle.code.cpp.rangeanalysis.SimpleRangeAnalysis
// ...
// select bufferSizeExpr, buffer, access, allocatedUnits, maxAccessedIndex

/**
 * Compute the maximum accessed index.
 */
predicate computeMaxAccess(ArrayExpr access, int maxAccessedIndex) {
  exists(
    int arrayTypeSize, int accessMax, Type arrayBaseType, int arrayBaseTypeSize, Expr accessIdx
  |
    // buf[...]
    // ^^^^^^^^  ArrayExpr access
    //     ^^^
    accessIdx = access.getArrayOffset() and
    upperBound(accessIdx) = accessMax and
    arrayBaseType.getSize() = arrayBaseTypeSize and
    access.getArrayBase().getUnspecifiedType().(PointerType).getBaseType() = arrayBaseType and
    arrayTypeSize = access.getArrayBase().getUnspecifiedType().(PointerType).getBaseType().getSize() and
    arrayTypeSize * accessMax = maxAccessedIndex
  )
}

/**
 * Compute the allocation size.
 */
bindingset[bufferSize]
predicate computeAllocationSize(AllocationExpr buffer, int bufferSize, int allocatedUnits) {
  exists(int bufferBaseTypeSize, Type arrayBaseType, int arrayBaseTypeSize |
    // buf[...]
    // ^^^^^^^^  ArrayExpr access
    //     ^^^
    buffer.getSizeMult() = bufferBaseTypeSize and
    arrayBaseType.getSize() = arrayBaseTypeSize and
    bufferSize * bufferBaseTypeSize = allocatedUnits
  )
}

/**
 * Compute the allocation size and the maximum accessed index for the allocation and access.
 */
bindingset[bufferSize]
predicate computeIndices(
  ArrayExpr access, AllocationExpr buffer, int bufferSize, int allocatedUnits, int maxAccessedIndex
) {
  exists(
    int arrayTypeSize, int accessMax, int bufferBaseTypeSize, Type arrayBaseType,
    int arrayBaseTypeSize, Expr accessIdx
  |
    // buf[...]
    // ^^^^^^^^  ArrayExpr access
    //     ^^^
    accessIdx = access.getArrayOffset() and
    upperBound(accessIdx) = accessMax and
    buffer.getSizeMult() = bufferBaseTypeSize and
    arrayBaseType.getSize() = arrayBaseTypeSize and
    bufferSize * bufferBaseTypeSize = allocatedUnits and
    access.getArrayBase().getUnspecifiedType().(PointerType).getBaseType() = arrayBaseType and
    arrayTypeSize = access.getArrayBase().getUnspecifiedType().(PointerType).getBaseType().getSize() and
    arrayTypeSize * accessMax = maxAccessedIndex
  )
}

/**
 * Gets an expression that flows to the allocation (which includes those already in the allocation)
 * and has a constant value.
 */
predicate getAllocConstantExpr(Expr bufferSizeExpr, int bufferSize) {
  exists(AllocationExpr buffer |
    // Capture BOTH with datflow:
    // 1. malloc (100)
    //            ^^^ bufferSize
    // 2. unsigned long size = 100; ... ; char *buf = malloc(size);
    DataFlow::localExprFlow(bufferSizeExpr, buffer.getSizeExpr()) and
    bufferSizeExpr.getValue().toInt() = bufferSize
  )
}
