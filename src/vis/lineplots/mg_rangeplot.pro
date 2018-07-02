; docformat = 'rst'

;+
; Create a standard direct graphics line plot, but clip y-axis to a given range
; and indicate clipped values.
;-
pro mg_rangeplot, x, y, $
                  ystyle=ystyle, $
                  yrange=yrange, $
                  clip_color=clip_color, $
                  clip_psym=clip_psym, $
                  clip_linestyle=clip_linestyle, $
                  clip_symsize=clip_symsize, $
                  clip_thick=clip_thick, $
                  _extra=e
  compile_opt strictarr

  case n_params() of
    1: _y = x
    2: _y = y
    else: message, 'incorrect number of arguments'
  endcase

  if (n_elements(yrange) ne 2) then begin
    message, 'YRANGE keyword value invalid'
  endif

  _clip_color     = mg_default(clip_color, 'ffffff'x)
  _clip_psym      = mg_default(clip_psym, 0)
  _clip_linestyle = mg_default(clip_linestyle, 3)
  _clip_symsize   = mg_default(clip_symsize, 0.25)
  _clip_thick     = mg_default(clip_thick, 1.0)

  plot, x, y, ystyle=ystyle or 1, yrange=yrange, _extra=e

  big_ind = where(_y gt yrange[1], big_count, $
                  complement=good_ind, ncomplement=good_count)
  if (big_count gt 0L) then begin
    big_y = y
    big_y[big_ind] = yrange[1]
    big_y[good_ind] = !values.f_nan

    plots, x, big_y, $
           color=_clip_color, linestyle=_clip_linestyle, $
           psym=_clip_psym, symsize=_clip_symsize, $
           thick=_clip_thick
  endif

  small_ind = where(_y lt yrange[0], small_count, $
                    complement=good_ind, ncomplement=good_count)
  if (big_count gt 0L) then begin
    small_y = y
    small_y[small_ind] = yrange[0]
    small_y[good_ind] = !values.f_nan

    plots, x, small_y, $
           color=_clip_color, linestyle=_clip_linestyle, $
           psym=_clip_psym, symsize=_clip_symsize, $
           thick=_clip_thick
  endif
end


; main-level example program

n = 2L
x = findgen(n * 360) * !dtor
y = sin(x)

k = 10L
coeffs = randomu(seed, k)
periods = 10.0 * randomu(seed, k)
for i = 0L, k - 1L do y += 0.25 * (coeffs[i] - 0.5) * sin(periods[i] * x)

device, decomposed=1
mg_rangeplot, x, y, xstyle=9, ystyle=8, yrange=[-1.0, 1.0], $
              linestyle=4, $
              clip_color='0000ff'x, clip_thick=5.0

end
