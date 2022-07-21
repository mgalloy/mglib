; docformat = 'rst'

;+
; Overplot onto a plot produced my `mg_range_plot`.
;
;-
pro mg_range_oplot, x, y, $
                    clip_color=clip_color, $
                    clip_psym=clip_psym, $
                    clip_linestyle=clip_linestyle, $
                    clip_symsize=clip_symsize, $
                    clip_thick=clip_thick, $
                    _extra=e
  compile_opt strictarr

  case n_params() of
    1: begin
        _x = findgen(n_elements(x))
        _y = x
      end
    2: begin
        _x = x
        _y = y
      end
    else: message, 'incorrect number of arguments'
  endcase

  _clip_color     = mg_default(clip_color, 'ffffff'x)
  _clip_psym      = mg_default(clip_psym, 0)
  _clip_linestyle = mg_default(clip_linestyle, 3)
  _clip_symsize   = mg_default(clip_symsize, 0.25)
  _clip_thick     = mg_default(clip_thick, 1.0)

  good_indices = where(_x ge !x.crange[0] and _x le !x.crange[1] $
                         and _y ge !y.crange[0] and _y le !y.crange[1], $
                         n_good)

  if (n_good gt 0L) then oplot, _x[good_indices], _y[good_indices], _extra=e

  big_y_ind = where(_y gt !y.crange[1], big_y_count, $
                    complement=good_ind, ncomplement=good_count)
  if (big_y_count gt 0L) then begin
    big_y = _y
    big_y[big_y_ind] = !y.crange[1]
    big_y[good_ind] = !values.f_nan
    
    plots, _x, big_y, $
           color=_clip_color, $
           linestyle=_clip_linestyle, $
           psym=_clip_psym, $
           symsize=_clip_symsize, $
           thick=_clip_thick
  endif

  small_y_ind = where(_y lt !y.crange[0], small_y_count, $
                      complement=good_ind, ncomplement=good_count)
  if (small_y_count gt 0L) then begin
    small_y = _y
    small_y[small_y_ind] = !y.crange[0]
    small_y[good_ind] = !values.f_nan
    
    plots, _x, small_y, $
           color=_clip_color, $
           linestyle=_clip_linestyle, $
           psym=_clip_psym, $
           symsize=_clip_symsize, $
           thick=_clip_thick
  endif

  big_x_ind = where(_x gt !x.crange[1], big_x_count, $
                    complement=good_ind, ncomplement=good_count)
  if (big_x_count gt 0L) then begin
    big_x = _x
    big_x[big_x_ind] = !x.crange[1]
    big_x[good_ind] = !values.f_nan
    
    plots, big_x, _y, $
           color=_clip_color, $
           linestyle=_clip_linestyle, $
           psym=_clip_psym, $
           symsize=_clip_symsize, $
           thick=_clip_thick
  endif
  
  small_x_ind = where(_x lt !x.crange[0], small_x_count, $
                      complement=good_ind, ncomplement=good_count)
  if (small_x_count gt 0L) then begin
    small_x = _x
    small_x[small_x_ind] = !x.crange[0]
    small_x[good_ind] = !values.f_nan
    
    plots, small_x, _y, $
           color=_clip_color, $
           linestyle=_clip_linestyle, $
           psym=_clip_psym, $
           symsize=_clip_symsize, $
           thick=_clip_thick
  endif
end


; main-level example program

n = 2L
x = findgen(n * 360) * !dtor
y1 = sin(x)

k = 10L
coeffs = randomu(seed, k)
periods = 10.0 * randomu(seed, k)
for i = 0L, k - 1L do y1 += 0.25 * (coeffs[i] - 0.5) * sin(periods[i] * x)

device, decomposed=1
mg_range_plot, x, y1, $
               xstyle=9, ystyle=8, yrange=[-1.0, 1.0], $
               linestyle=4, $
               clip_color='0000ff'x, clip_thick=5.0

y2 = sin(x)
coeffs = randomu(seed, k)
periods = 10.0 * randomu(seed, k)
for i = 0L, k - 1L do y2 += 0.25 * (coeffs[i] - 0.5) * sin(periods[i] * x)
x = x[0:*:5]
y = y2[0:*:5]
mg_range_oplot, x, y2, $
                psym=2, symsize=1.0, $
                clip_color='00ff00'x, clip_psym=4, clip_symsize=1.0

end
