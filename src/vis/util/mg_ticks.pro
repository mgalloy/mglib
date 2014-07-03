; docformat = 'rst'

pro mg_ticks_tickinc, diff, potential_increments, potential_ticks, $
                      ticks=ticks, increment=increment
  compile_opt strictarr

  ; lonarr(increments, ticks)
  m = rebin(reform(potential_increments, n_elements(potential_increments), 1), $
            n_elements(potential_increments), n_elements(potential_ticks)) $
        * rebin(reform(potential_ticks, 1, n_elements(potential_ticks)), $
                n_elements(potential_increments), n_elements(potential_ticks))

  m_ind = sort(m)
  match_ind = value_locate(m[m_ind], diff)
  match_ind = match_ind > 0
  match_ind = match_ind < (n_elements(m) - 1L)
  match_pos = array_indices(m, m_ind[match_ind])

  ticks = potential_ticks[match_pos[1]]
  increment = potential_increments[match_pos[0]]

  if ((ticks + 1L) * increment lt diff) then begin
    match_pos = array_indices(m, m_ind[match_ind + 1L])
    ticks = potential_ticks[match_pos[1]]
    increment = potential_increments[match_pos[0]]
  endif
end

;+
; Calculates `[xyz]ticks`, `[xyz]range`, and `[xyz]tickv` for axis values.
;
; :Returns:
;   `[xyz]ticks` as long
;
; :Params:
;   values : in, required, type=numeric array
;     axis values
;
; :Keywords:
;   range : out, optional, type=fltarr(2)
;     range for `[xyz]range` keywords
;   tickv : out, optional, type=fltarr
;     tick values for `[xyz]tickv` keywords
;-
function mg_ticks, values, range=range, tickv=tickv
  compile_opt strictarr

  r = mg_range(values)
  diff = r[1] - r[0]

  ; preferred spacing between tick marks
  potential_increments = [1, 5, 10, 25]

  ; ticks should be in the range of 4 to 10
  potential_ticks = lindgen(7) + 4L

  mg_ticks_tickinc, diff, potential_increments, potential_ticks, $
                    ticks=ticks, increment=increment

  start = long(r[0] / increment) * increment
  if (start eq r[0]) then begin
    tickv = increment * findgen(ticks + 1L) + start
  endif else begin
    ticks--
    tickv = increment * (findgen(ticks + 1L) + 1.0) + start
  endelse

  ; expand range to include tickmarks
  range = mg_range_union(r, mg_range(tickv))

  potential_end = ceil(r[1] / increment) * increment
  error = potential_end - range[1]
  if (error gt 0.0 && error lt 0.1 * increment) then begin
    ticks++
    tickv = [tickv, tickv[-1] + increment]
  endif

  ; expand range to include tickmarks
  range = mg_range_union(r, mg_range(tickv))

  if (range[0] lt tickv[0]) then begin
    ticks++
    tickv = [tickv[0] - increment, tickv]
  endif

  return, ticks
end


; main-level example program

n = 100L
x = findgen(n) * 0.25 + 25.0
y = x^2 / 100.

xticks = mg_ticks(x, range=xrange, tickv=xtickv)
yticks = mg_ticks(y, range=yrange, tickv=ytickv)
plot, x, y, $
      xticks=xticks, xrange=xrange, xtickv=xtickv, xstyle=9, $
      yticks=yticks, yrange=yrange, ytickv=ytickv, ystyle=9

ticks = mg_ticks([6.25000, 24.7506], range=range, tickv=tickv)

window, /free
plot, x, y

end
