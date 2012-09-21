; docformat = 'rst'

;+
; Produce a `ternary plot <http://en.wikipedia.org/wiki/Ternary_plot>`.
;
; :Examples:
;    Try the main-level example program at the end of this file::
;
;       IDL> .run vis_ternaryplot
;
;    The first example does::
;
;       d = read_csv(filepath('ternary_data.txt', root=vis_src_root()))
;       vis_ternaryplot, d.field2, d.field3, d.field4, psym=5, $
;                        color='000000'x, background='ffffff'x, $
;                        atitle='aerosol single scattering albedo', $
;                        btitle='Angstrom exponent', $
;                        ctitle='back-scattering fraction'
; 
;    This should produce the following:
; 
;    .. image:: ternary_data.png
;
;    The next example does::
;
;       n = 1000L
;       a = randomu(seed, n)
;       b = randomu(seed, n)
;       c = randomu(seed, n)
;       vis_ternaryplot, color='000000'x, background='ffffff'x, /nodata, $
;                        atitle='A', btitle='B', ctitle='C'
;       vis_ternaryplot, a + 2., b, c, psym=1, symsize=0.5, color=rgb[0], /overplot
;       vis_ternaryplot, a, b + 2., c, psym=1, symsize=0.5, color=rgb[1], /overplot
;       vis_ternaryplot, a, b, c + 2., psym=1, symsize=0.5, color=rgb[2], /overplot
;       vis_ternaryplot, a + 1., b, c + 2., psym=1, symsize=0.5, color=rgb[3], /overplot
;       vis_ternaryplot, a, b + 2., c + 1., psym=1, symsize=0.5, color=rgb[4], /overplot
;       vis_ternaryplot, a + 2., b + 1., c, psym=1, symsize=0.5, color=rgb[5], /overplot
; 
;    It should produce the following:
;
;    .. image:: ternary_sample.png
;-


;+
; Create a ternary plot.
; 
; :Params:
;    a : in, required, type=fltarr
;       closer to lower left indicates higher `a` value
;    b : in, required, type=fltarr
;       closer to lower right indicates higher `b` value
;    c : in, required, type=fltarr
;       closer to upper middle indicates higher `c` value
;
; :Keywords:
;    atitle : in, optional, type=string
;       title for `a` values
;    btitle : in, optional, type=string
;       title for `b` values
;    ctitle : in, optional, type=string
;       title for `c` values
;    xmargin : in, optional, type=fltarr(2)
;       x-margins for plot in units of characters
;    ymargin : in, optional, type=fltarr(2)
;       y-margins for plot in units of characters
;    overplot : in, optional, type=boolean
;       set to overplot on a previously setup coordinate system
;    nodata : in, optional, type=boolean
;       set to create a coordinate system without plotting any data
;    _extra : in, optional, type=keywords
;       keywords for `PLOT`, `PLOTS`, and `XYOUTS`
;-
pro vis_ternaryplot, a, b, c, $
                     atitle=atitle, btitle=btitle, ctitle=ctitle, $
                     xmargin=xmargin, ymargin=ymargin, $
                     overplot=overplot, nodata=nodata, $
                     _extra=e
  compile_opt strictarr

  ; save system variable
  orig_t3d = !p.t
  orig_xmargin = !x.margin
  orig_ymargin = !y.margin
  
  margin = 1.5 ; cm
  !x.margin = n_elements(xmargin) eq 0L $
                ? (fltarr(2) + margin * !d.x_px_cm / !d.x_ch_size) $
                : xmargin
  !y.margin = n_elements(ymargin) eq 0L $
                ? (fltarr(2) + margin * !d.y_px_cm / !d.y_ch_size) $
                : ymargin
  
  if (~keyword_set(overplot)) then begin
    plot, [0., 1.], [0., 1.], xstyle=9, ystyle=5, /nodata, /isotropic, _extra=e

    angle = atan(1. / sqrt(3) * !d.y_size / !d.x_size) * !radeg
    scale = sqrt(3) / 2. / cos(angle * !dtor)

    offset = [- (!x.s[0] + !x.s[1] * 0.), - (!y.s[0] + !y.s[1] * 0.), 0.]
    t3d, /reset
    t3d, translate=offset, rotate=[0., 0., - angle]
    t3d, scale=[scale, scale, 1.]
    t3d, translate=-offset
    axis, 0., 0., yaxis=0, /t3d, yrange=[1., 0.], _extra=e

    offset = [- (!x.s[0] + !x.s[1] * 1.), - (!y.s[0] + !y.s[1] * 0.), 0.]
    t3d, /reset
    t3d, translate=offset, rotate=[0., 0., angle]
    t3d, scale=[scale, scale, 1.]
    t3d, translate=-offset
    axis, 1., 0., yaxis=1, /t3d, _extra=e
    t3d, /reset

    ; convert character heights to data coordinates
    charheight = (1.0 * !d.y_ch_size / !d.y_size) / !y.s[1]
    
    if (n_elements(atitle) gt 0L) then begin
      xyouts, 0., 0. - 3. * charheight, atitle, alignment=0., _extra=e
    endif
    
    if (n_elements(btitle) gt 0L) then begin
      xyouts, 0.5, sqrt(3) / 2. + 2. * charheight, btitle, alignment=0.5, _extra=e
    endif
    
    if (n_elements(ctitle) gt 0L) then begin
      xyouts, 1., 0. - 3. * charheight, ctitle, alignment=1., _extra=e
    endif
  endif  
  
  if (~keyword_set(nodata)) then begin
    constant = a + b + c
  
    _a = a / constant
    _b = b / constant
    _c = c / constant
    
    x = _b + _c / 2.
    y = sqrt(3) / 2. * _c
    
    plots, x, y, psym=4, _extra=e
  endif
  
  ; restore system variables
  !p.t = orig_t3d
  !x.margin = orig_xmargin
  !y.margin = orig_ymargin
end


; main-level program

d = read_csv(filepath('ternary_data.txt', root=vis_src_root()))

if (keyword_set(ps)) then vis_psbegin, filename='ternary_data.ps', /image

vis_decomposed, 1, old_decomposed=old_dec

vis_window, xsize=14, ysize=14, /free
vis_ternaryplot, d.field2, d.field3, d.field4, psym=5, $
                 color='000000'x, background='ffffff'x, $
                 atitle='aerosol single scattering albedo', $
                 btitle='Angstrom exponent', $
                 ctitle='back-scattering fraction'

vis_decomposed, old_dec

if (keyword_set(ps)) then begin
  vis_psend
  vis_convert, 'ternary_data', max_dimensions=[400, 400], output=im
  vis_image, im, /new_window
endif

n = 1000L
a = randomu(seed, n)
b = randomu(seed, n)
c = randomu(seed, n)

if (keyword_set(ps)) then vis_psbegin, filename='ternary_sample.ps', /image

vis_loadct, 32, /brewer, rgb_table=rgb
rgb = vis_rgb2index(rgb)

vis_decomposed, 1, old_decomposed=old_dec

vis_window, xsize=14, ysize=14, /free
vis_ternaryplot, color='000000'x, background='ffffff'x, /nodata, $
                 atitle='A', btitle='B', ctitle='C'
vis_ternaryplot, a + 2., b, c, psym=1, symsize=0.5, color=rgb[0], /overplot
vis_ternaryplot, a, b + 2., c, psym=1, symsize=0.5, color=rgb[1], /overplot
vis_ternaryplot, a, b, c + 2., psym=1, symsize=0.5, color=rgb[2], /overplot
vis_ternaryplot, a + 1., b, c + 2., psym=1, symsize=0.5, color=rgb[3], /overplot
vis_ternaryplot, a, b + 2., c + 1., psym=1, symsize=0.5, color=rgb[4], /overplot
vis_ternaryplot, a + 2., b + 1., c, psym=1, symsize=0.5, color=rgb[5], /overplot

vis_decomposed, old_dec

if (keyword_set(ps)) then begin
  vis_psend
  vis_convert, 'ternary_sample', max_dimensions=[400, 400], output=im
  vis_image, im, /new_window
endif

end
