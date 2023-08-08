; docformat = 'rst'

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


function mg_tick_locator, range, months=months
  compile_opt strictarr

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
