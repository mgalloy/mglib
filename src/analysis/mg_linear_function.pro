; docformat = 'rst'

;+
; Create a function which maps `in_range` to `out_range` with a linear 
; function and returns the coefficients.
;
; :Examples: 
;    To create a linear function that maps the `x`-range of a surface object 
;    to the range -0.75 to 0.75 use::
;
;       osurface->getProperty, xrange=xr
;       xc = mg_linear_function(xr, [-0.75, 0.75])
;       osurface->setProperty, xcoord_conv=xc
;
;    This provides a more flexible method of creating linear functions than
;    the typical::
;
;       osurface->getProperty, xrange=xr
;       xc = norm_coord(xr)
;       xr[0] -= 0.5
;       osurface->setProperty, xcoord_conv
;
;    which can only "normalize" the dimension i.e. make its size equal to 1
;    (not an aribitrary size like the `MG_LINEAR_FUNCTION` example).
;
; :Returns: 
;    2-element array of type of `in_range` and `out_range`
;
; :Params:
;    in_range : in, required, type=2-element numeric array
;       input range
;    out_range : in, required, type=2-element numeric array 
;       output range 
;-
function mg_linear_function, in_range, out_range
    compile_opt strictarr
    
    slope = float(out_range[1] - out_range[0]) / float(in_range[1] - in_range[0])
    return, [out_range[0] - slope * in_range[0], slope]
end
