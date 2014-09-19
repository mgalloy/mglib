; docformat = 'rst'

;+
; Create a LIC visualization where color denotes magnitude of the vector
; field.
;
; :Examples:
;   The following creates a color LIC visualization::
;
;     restore, filepath('globalwinds.dat', subdir=['examples','data'])
;     loadct, 3
;     mg_image, mg_colorlic(u, v, scale=4), /new_window, /no_axes
;
;   This looks like:
;
;   .. image:: colorlic-example.png
;
; :Returns:
;   `bytarr(3, m, n)`
;
; :Params:
;   u : in, required, type="fltarr(m, n)"
;     x-coordinates of vector field
;   v : in, required, type="fltarr(m, n)"
;     y-coordinates of vector field
;
; :Keywords:
;   scale : in, optional, type=long, default=1L
;     factor to REBIN u and v by
;   log : in, optional, type=boolean
;     set to use log scale for image values
;   _extra : in, optional, type=keywords
;     keywords to `MG_LIC` or `MG_MAKETRUE`
;-
function mg_colorlic, u, v, scale=scale, log=log, _extra=e
  compile_opt strictarr

  _scale = n_elements(scale) eq 0L ? 1L : scale
  dims = size(u, /dimensions)
  _u = rebin(u, dims[0] * _scale, dims[1] * _scale)
  _v = rebin(v, dims[0] * _scale, dims[1] * _scale)

  im = mg_lic(_u, _v, _extra=e)
  mag = sqrt(_u * _u + _v * _v)

  if (!d.name eq 'WIN' || !d.name eq 'X' || !d.name eq 'Z') then begin
    device, get_decomposed=dec
    device, decomposed=0
  endif

  im *= mag
  if (keyword_set(log)) then im = alog10(im)
  trueIm = mg_maketrue(bytscl(im), true=1, _extra=e)

  if (!d.name eq 'WIN' || !d.name eq 'X' || !d.name eq 'Z') then begin
    device, decomposed=dec
  endif

  return, trueIm
end


; main-level example program

restore, filepath('globalwinds.dat', subdir=['examples','data'])

loadct, 3
mg_image, mg_colorlic(u, v, scale=4), /new_window, /no_axes

end
