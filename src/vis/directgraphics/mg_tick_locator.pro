; docformat = 'rst'

;+
; Find the tick values based on some condition, such as the start of months,
; etc.
;-

function mg_tick_locator_next_month, jd, is_start=is_start
  compile_opt strictarr

  caldat, jd, month, day, year
  is_start = day eq 1L

  ; increment month
  month += 1L
  day    = 1L

  if (month gt 12L) then begin
    month = 1L
    year += 1L
  endif

  return, julday(month, day, year, 0, 0, 0)
end


;+
; Find the tick values based on some condition, such as the start of months,
; etc.
;
; :Returns:
;   array of the same type as range, or double if `MONTHS` is set; `!null` if
;   ticks cannot be found
;
; :Params:
;   range : in, required, type=fltarr(2) or other numeric type
;     numeric range of values, i.e., `[min, max]`
;
; :Keywords:
;   max_ticks : in, optional, type=integer, default=60L
;     maximum number of tick marks to show; the default is 60, which matches
;     the maximum number of tick marks allowed in graphics routines like
;     `PLOT`
;   minor : out, optional, type=integer
;     set to a named variable to retrieve a value that `{X,Y,Z}MINOR` could be
;     set to, i.e., the number of minor intervals between tick values; this is
;     needed when the `MAX_TICKS` forces that not every tick mark be shown
;   months : in, optional, type=boolean
;     set to interpret `range` as Julian dates and find tick values that
;     correspond to the start of months
;-
function mg_tick_locator, range, max_ticks=max_ticks, minor=minor, months=months
  compile_opt strictarr

  _max_ticks = mg_default(max_ticks, 60L)

  if (keyword_set(months)) then begin
    v = list()
    next_month = mg_tick_locator_next_month(range[0], is_start=is_start)
    if (is_start) then v->add, range[0]
    while (next_month lt range[1]) do begin
      v->add, next_month
      next_month = mg_tick_locator_next_month(next_month)
    endwhile
    if (v->isEmpty()) then v->add, next_month
    months_array = v->toArray()
    obj_destroy, v

    n_ticks = n_elements(months_array)
    if (n_ticks gt _max_ticks) then begin
      minor = ceil(float(n_ticks) / _max_ticks)
      months_array = months_array[0:*:minor]
    endif else minor = 1L

    return, months_array
  endif

  return, !null
end


; main-level example

n = 365
jds = timegen(n, units='days') + systime(/julian)
data = randomu(seed, n)
data = smooth(smooth(data, 5), 5)

xtickv = mg_tick_locator([jds[0], jds[-1]], /months)

window, xsize=1200, ysize=300, /free, title='MG_TICK_LOCATOR /MONTHS example'
!null = label_date(date_format='%Y-%N-%D')
plot, jds, data, $
      charsize=1.2, $
      xstyle=1, $
      xrange=[jds[0], jds[-1]], $
      xtickformat='label_date', $
      xtickv=xtickv, $
      xticks=n_elements(xtickv) - 1L

end
