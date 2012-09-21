; docformat = 'rst'

;+
; Create a function which maps in_range to out_range with a linear function.
;
; :Categories:
;    graphics computation
;
; :Examples: 
;    To create a linear function that maps the x-range of a surface object to 
;    the range -0.75 to 0.75 use::
;
;       osurface->getProperty, xrange=xr
;       xc = vis_linear_function(xr, [-0.75, 0.75])
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
;    (not an aribitrary size like the VIS_LINEAR_FUNCTION example). 
;-

;+
; Create a function which maps in_range to out_range with a linear function.
;
; :Returns: 
;    2-element array of type of in_range and out_range; or scaled data if 
;    DATA keyword is present
;
; :Params:
;    in_range : in, required, type=2-element numeric array
;       input range
;    out_range : in, required, type=2-element numeric array 
;       output range
;
; :Keywords:
;    data : in, optional, type=fltarr
;       data to scale
;-
function vis_linear_function, in_range, out_range, data=data
    compile_opt strictarr
    
    slope = float(out_range[1] - out_range[0]) / float(in_range[1] - in_range[0])
    lf = [out_range[0] - slope * in_range[0], slope]
    
    if (n_elements(data) gt 0L) then begin
      return, lf[0] + data * lf[1]
    endif else return, lf
end
