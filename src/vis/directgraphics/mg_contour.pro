; docformat = 'rst'

;+
; Wrapper for CONTOUR that handles the NLEVELS keyword better: if LEVELS is 
; not specified then NLEVELS contour levels are created equally spaced between
; the minimum and maximum values of z. The levels used can also be returned
; to the caller by passing a named variable to LEVELS.
;
; :Categories:
;    direct graphics
;
; :Examples:
;    Try the main-level example program at the end of this file::
; 
;       IDL> .run vis_contour
;
;    This should produce something like:
;
;    .. image:: elevbin.png
;
;    After reading in the elevbin.dat dataset, the pertinent commands are::
;
;       IDL> vis_contour, data, /fill, nlevels=15, xstyle=1, ystyle=1, $
;            title='VIS_CONTOUR'
;       IDL> vis_contour, data, /overplot, nlevels=15, levels=levels, $
;            /follow, /downhill
;       IDL> print, 'Levels used in VIS_CONTOUR: ' $
;              + strjoin(strtrim(levels, 2), ', ')
;-

;+
; Produce a contour plot.
;
; :Params:
;    z : in, required, type="fltarr(m, n)"
;       2-dimensional array to be plotted
;    x : in, optional, type=fltarr(m)
;       values for x-axis
;    y : in, optional, type=fltarr(n)
;       values for y-axis
;
; :Keywords:
;    nlevels : in, optional, type=integer, default=6
;       number of contour levels
;    levels : in, out, optional, type=fltarr
;       values for isocline levels; specified values are used if present, set
;       to a named variable to output the used levels if not
;    _extra : in, optional, type=keywords
;       keywords to CONTOUR
;-
pro vis_contour, z, x, y, nlevels=nlevels, levels=levels, _extra=e
  compile_opt strictarr
  on_error, 2
  
  _nlevels = n_elements(nlevels) gt 0L ? nlevels : 6
  
  ; if LEVELS is not specified, use _nlevels to compute them
  if (n_elements(levels) eq 0) then begin
    step = (float(max(z)) - float(min(z))) / float(_nlevels)
    levels = findgen(_nlevels) * step + min(z)
  endif
  
  case n_params() of 
    1: contour, z, levels=levels, _extra=e
    3: contour, z, x, y, levels=levels, _extra=e
    else: message, 'incorrect number of arguments'
  endcase
end


; main-level program example

filename = filepath('elevbin.dat', subdir=['examples', 'data'])
data = bytarr(64, 64)
openr, lun, filename, /get_lun
readu, lun, data
free_lun, lun

device, decomposed=0
vis_loadct, 5, /brewer

window, /free, title='VIS_CONTOUR example', xsize=800, ysize=400

!p.multi = [0, 2, 1]

contour, data, /fill, nlevels=15, xstyle=1, ystyle=1, title='CONTOUR'
contour, data, /overplot, nlevels=15, /follow, /downhill

vis_contour, data, /fill, nlevels=15, xstyle=1, ystyle=1, title='VIS_CONTOUR'
vis_contour, data, /overplot, nlevels=15, levels=levels, /follow, /downhill

print, 'Levels used in VIS_CONTOUR: ' + strjoin(strtrim(levels, 2), ', ')

!p.multi = 0

end