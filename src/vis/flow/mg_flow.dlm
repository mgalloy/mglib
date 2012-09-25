MODULE MG_FLOW
DESCRIPTION Flow visualization
VERSION 1.0
SOURCE mgalloy
BUILD_DATE Apr 7 2008

#+
# Compute the line integral convolution for a vector field.
#
# :Returns:
#    bytarr(m, n)
# 
# :Params:
#    u : in, required, type="fltarr(m, n)"
#       x-coordinates of vector field
#    v : in, required, type="fltarr(m, n)"
#       y-coordinates of vector field
#
# :Keywords:
#    texture : in, optional, type="bytarr(m, n)"
#       random texture map; it is useful to use the same texture map for 
#       generating frames of a movie
#-
FUNCTION MG_LIC 2 2 KEYWORDS
