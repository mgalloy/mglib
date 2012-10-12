MODULE mg_lineplots
DESCRIPTION Line plot visualization
VERSION 1.0
SOURCE mgalloy
BUILD_DATE 19 June 2009

#+
# Rasterize a polyline.
#
# :Returns:
#    `lonarr(n1, n2)`
# 
# :Params:
#    x : in, required, type=`fltarr(n)`
#       x-coordinates of polyline
#    y : in, required, type=`fltarr(n)`
#       y-coordinates of polyline
#-
FUNCTION MG_RASTERPOLYLINE 6 6
