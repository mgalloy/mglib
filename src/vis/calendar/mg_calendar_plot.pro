; docformat = 'rst'

;+
; :Params:
;   year : in, required, type=string
;     year to plot
;   dates : in, required, type=strarr
;     array of dates in the form 'YYYYMMDD'
;   values : in, required, type=strarr
;     values to plot
;
; :Keywords:
;   start_on : in, optional, type=integer
;     day of week to start weeks on: 0=Sunday, 1=Monday, ... 6=Saturday
;-
pro mg_calendar_plot, year, dates, values, start_on=start_on
  compile_opt strictarr

  ;; calendar calculations

  _start_on = mg_default(start_on, 0)

  months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', $
            'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec']

  days_of_week = ['Su', 'M', 'T', 'W', 'Th', 'F', 'Sa']
  days_of_week = shift(days_of_week, - _start_on)

  n_days_per_month = [31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
  is_leap_year = 1B

  start_day = (julday(1, 1, year) + 1) mod 7
  start_day_next_year = (julday(1, 1, (year eq -1) ? 1 : year + 1) + 1) mod 7

  if (((start_day_next_year + 7 - start_day) mod 7) eq 1) or (year eq 1582) then begin
    ; not a leap year
    n_days_per_month[1] = 28
    is_leap_year = 0B
  endif

  ; you need 53 rows to display a calendar because 52 * 7 = 364 -- UNLESS it is
  ; a leap year and the first day of the year is on the last day of the week
  ; (in that case, you have 2 rows with a single day and 52 full rows)
  if (is_leap_year && start_day eq (_start_on - 1) mod 7) then begin
    n_rows = 54
  endif else n_rows = 53


  ;; grouping values
  n_values = n_elements(values)
  h = mg_str_histogram(values, locations=unique_values, reverse_indices=ri)

  fill_indices = lonarr(n_values)
  for u = 0L, n_elements(unique_values) - 1L do begin
    fill_indices[ri[ri[u]:ri[u + 1] - 1]] = u mod 12
  endfor

  ;; graphics

  n_rows   += 1   ; add a row for day of week labels
  n_columns = 7   ; always 7 days/week

  ; in normal coordinates...
  top_margin    = 0.050
  right_margin  = 0.400
  bottom_margin = 0.025
  left_margin   = 0.050
  month_gap     = 0.025   ; gap between right size of plot and month names

  title_charsize = 1.25
  week_charsize  = 1.00
  date_charsize  = 0.75

  device, get_decomposed=original_decomposed
  device, decomposed=1

  tvlct, original_rgb, /get
  mg_loadct, 27, /brewer   ; there are 12 colors in ColorBrewer Set3
  tvlct, rgb, /get

  ct = mg_rgb2index(rgb[0:11, *])

  window, xsize=450, ysize=1000, /free, title=year

  background_color = 'ffffff'x
  border_color     = '000000'x
  label_color      = '0000ff'x
  date_color       = '606060'x

  erase, background_color

  column_width = (1.0 - left_margin - right_margin) / n_columns
  row_height = (1.0 - top_margin - bottom_margin) / n_rows

  ; year label
  xyouts, (left_margin + 1.0 - right_margin) / 2.0, 1.0 - top_margin / 2.0, year, $
          alignment=0.5, charsize=title_charsize, color=label_color

  ; day of week labels
  for d = 0L, n_elements(days_of_week) - 1L do begin
    xyouts, left_margin + (d + 0.5) * column_width, $
            bottom_margin + (n_rows - 0.7) * row_height, $
            days_of_week[d], $
            alignment=0.5, charsize=week_charsize, color=label_color
  endfor

  i = 0                              ; index into values
  r = 0                              ; row index
  c = (start_day - start_on) mod 7   ; column index
  m = 0                              ; month index
  day_of_month = 1

  for d = 0L, 365L + is_leap_year - 1L do begin
    x = left_margin + (c + 0.9) * column_width
    y = bottom_margin + (n_rows - 1 - r - 0.7) * row_height

    if (day_of_month eq 1) then begin
      xyouts, 1.0 - right_margin + month_gap, y, months[m], $
              /normal, charsize=week_charsize, color=label_color
    endif

    date = string(year, m + 1, day_of_month, format='(%"%04d%02d%02d")')
    if (i lt n_elements(dates) && date eq dates[i]) then begin
      fill_color = ct[fill_indices[i]]
      polyfill, left_margin + (c + [0, 1, 1, 0, 0]) * column_width, $
                bottom_margin + (n_rows - 1 - r + [0, 0, -1, -1, 0]) * row_height, $
                color=fill_color, /normal
      i += 1
    endif

    xyouts, x, y, strtrim(day_of_month, 2), $
            alignment=1.0, /normal, charsize=date_charsize, color=date_color

    c += 1
    if (c ge 7) then begin
      r += 1
      c = 0
    endif

    day_of_month += 1
    if (day_of_month gt n_days_per_month[m]) then begin
      day_of_month = 1
      m += 1
    endif
  endfor

  ; vertical borders
  for c = 0L, n_columns do begin
    plots, fltarr(2) + left_margin + c * column_width, $
           [1.0 - top_margin, bottom_margin], $
           /normal, color=border_color
  endfor

  ; horizontal borders
  for r = 0L, n_rows do begin
    plots, [left_margin, 1.0 - right_margin], $
           fltarr(2) + bottom_margin + r * row_height, $
           /normal, color=border_color
  endfor

  ; legend
  legend_line_height = 0.025
  usersym, [-1, 1, 1, -1, -1], [1, 1, -1, -1, 1], /fill
  sorted_indices = sort(unique_values)
  for u = 0L, n_elements(unique_values) - 1L do begin
    x = 1.0 - right_margin + 6 * month_gap
    y = 1.0 - top_margin - (u + 2) * legend_line_height
    plots, x, y, psym=8, symsize=2.0, /normal, color=ct[sorted_indices[u]]
    xyouts, x + month_gap, y - 0.0025, unique_values[sorted_indices[u]], $
            /normal, color=date_color
  endfor

  device, decomposed=original_decomposed
  tvlct, original_rgb
end
