# bignum
Basic math functions in LiveCode, coded to handle any length arguments.

**Functions List**

 * function bigAdd -- returns the sum of X and Y
 * function bigAddSigned -- handles positive and negative arguments
 * function bigSubtract -- returns the difference between X and Y
 * function bigSubtractSigned -- handles positive and negative arguments
 * function bigTimes -- returns the product of X and Y
 * function bigTimesSigned -- handles positive and negative arguments
 * function bigDiv -- returns (X div Y),(X mod Y)
 * function bigDivSigned -- handles positive and negative arguments
 * function bigishDiv -- Handles any length dividend; divisor must be a valid LC number (< 16 digits)
 * function bigDivFlawed -- About 40% faster than bigDiv, but can bork the last few digits of the quotient. Included in case anyone sees the logic error.
 * function bigCompare -- Applies >,<,=,<=,>= to any length arguments
 * function stripLeadingZeros -- returns any string without whatever leading zeros it contains


Functions are coded to accept two arguments of any length except as noted for bigishDiv. Each function comes in a signed and unsigned form except bigCompare, stripLeadingZeros, and bigishDiv. Those are TBD.

Optimizations are welcome.
