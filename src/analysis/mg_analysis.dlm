MODULE mg_analysis
DESCRIPTION Tools for analysis
VERSION 1.0
SOURCE mgalloy
BUILD_DATE January 18, 2011


#+
# Allows checking for two arrays for equality or being within a tolerance.
#
# :Returns:
#   1 if equal, 0 if not
#
# :Params:
#   array1 : in, required, type=array
#     first array to compare
#   array2 : in, required, type=array
#     second array to compare
#
# :Keywords:
#   tolerance : in, optional, type=numeric
#     tolerance to allow array elements to differ by
#   no_typeconv : in, optional, type=boolean
#     if set, immediately fail if types aren't the same
#-
FUNCTION MG_ARRAY_EQUAL      2 2 KEYWORDS


#+
# Uses the Kahan summation algorithm::
#
#   http://en.wikipedia.org/wiki/Kahan_summation_algorithm>
#
# :Returns:
#   total of elements of array
#
# :Params:
#   array : in, required, type=array
#     array to sum
#-
FUNCTION MG_TOTAL            1 1

