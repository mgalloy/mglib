; docformat = 'rst'


;+
; Return potential increments.
;
; :Private:
;
; :Returns:
;   `fltarr`
;
; :Keywords:
;   degrees : in, optional, type=boolean
;     set to indicate increments should be in degrees
;-
function mg_ticks_increments, degrees=degrees
  compile_opt strictarr

  ; preferred spacing between tick marks
  case 1 of
    keyword_set(degrees): potential_increments = [1., 5., 10., 45., 90.]
    else: potential_increments = [1., 2.5, 5.]
  endcase

  return, potential_increments
end


;+
; Determine ticks and increment.
;
; :Private:
;
; :Returns:
;   increment as a float
;
; :Params:
;   diff : in, required, type=float
;     range difference
;   potential_increments : in, required, type=lonarr
;     potential increments between ticks
;   potential_ticks : in, required, type=lonarr
;     potential number of ticks
;
; :Keywords:
;   ticks : out, optional, type=long
;     set to a named variable to return the number of tick marks
;-
function mg_ticks_tickinc, diff, $
                           potential_increments, $
                           potential_ticks, $
                           ticks=ticks, $
                           degrees=degrees
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

  ; if ticks/interval is not enough to cover the range
  if (ticks * increment lt diff) then begin
    if (match_ind lt n_elements(m) - 1L) then begin
      match_pos = array_indices(m, m_ind[match_ind + 1L])
      ticks = potential_ticks[match_pos[1]]
      increment = potential_increments[match_pos[0]]
    endif else begin
      if (keyword_set(degrees)) then begin
        potential_increments = mg_ticks_increments()
      endif else begin
        potential_increments = potential_increments * 10L
      endelse
      increment = mg_ticks_tickinc(diff, $
                                   potential_increments, $
                                   potential_ticks, $
                                   ticks=ticks)
    endelse
  endif

  return, increment
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
;   degrees : in, optional, type=boolean
;     set to indicate values are in degrees
;-
function mg_ticks, values, range=range, tickv=tickv, degrees=degrees
  compile_opt strictarr

  r = mg_range(values)
  diff = r[1] - r[0]

  potential_increments = mg_ticks_increments(degrees=degrees)

  ; ticks should be in the range of 3 to 10
  potential_ticks = lindgen(8) + 3L

  increment = mg_ticks_tickinc(diff, $
                               potential_increments, $
                               potential_ticks, $
                               ticks=ticks, degrees=degrees)

  range = fltarr(2)
  prange = [floor(r[0] / increment), ceil(r[1] / increment)] * increment

  if (r[0] - prange[0] gt 0.15 * increment || r[0] - prange[0] lt 0.0) then begin
    range[0] = r[0]
  endif else range[0] = prange[0]
  if (prange[1] - r[1] gt 0.15 * increment || prange[1] - r[1] lt 0.0) then begin
    range[1] = r[1]
  endif else range[1] = prange[1]

  increment = mg_ticks_tickinc(range[1] - range[0], $
                               potential_increments, $
                               potential_ticks, $
                               ticks=ticks, degrees=degrees)

  tickv = increment * findgen(ticks + 1L) + prange[0]

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
