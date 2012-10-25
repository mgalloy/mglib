; docformat = 'rst'

;+
; Produce a comparison chart as shown in the examples section.
;
; :Examples:
;    See the main-level example program::
;
;       IDL> .run mg_slopegraph
;
;    It should produce output like:
;
;    .. image:: receipts.png
;
;    The slopegraph concept and the data for this example were taken from *The
;    Visual Display of Quantitative Information* by Edward Tufte.
;
; :Categories:
;    direct graphics
;-

;+
; Spread out text lines that are too close to each other.
;
; :Returns:
;    fltarr
;
; :Params:
;    values : in, required, type=fltarr
;       values to spread
;    charHeight : in, required, type=float
;       height of a character in data coordinates
;    lineHeight : in, required, type=float
;       height of a line of text in data coordinates (baseline to baseline)
;
; :Bugs:
;    this should probably be an iterative process because fixing up the values
;    could actually cause more problems in certain cases
;-
function mg_slopegraph_spread, values, charHeight, lineHeight
  compile_opt strictarr

  sind = sort(values)
  _values = values[sind]
  __values = values

  _values -= 0.3 * charHeight

  shortIntervals = _values[1:n_elements(_values) - 1L] - _values[0:*] lt lineHeight
  problems = label_region([0, shortIntervals, 0])
  problems = problems[1:n_elements(problems) - 2]

  for p = 1L, max(problems) do begin
    ind = where(problems eq p)
    ind = [ind, max(ind) + 1L]
    v = _values[ind]
    center = mean(v)
    offsets = lineHeight * findgen(n_elements(ind))
    _values[ind] = offsets + center - mean(offsets)
  endfor

  __values[sind] = _values

  return, __values
end


;+
; Creates a comparison chart.
;
; :Params:
;    names : in, required, type=strarr
;       names of the items in the comparison
;    startValues : in, required, type=fltarr
;       starting values of the items in the same order as names
;    endValues : in, required, type=fltarr
;       ending values of the items in the same order as names
;
; :Keywords:
;    start_title : in, optional, type=string
;       title over column of starting values
;    end_title : in, optional, type=string
;       title over column of ending values
;    title : in, optional, type=string
;       main title
;    line_color : in, optional, type=long
;       color of lines
;    value_format : in, optional, type=string
;       format code for printing values
;    text_color : in, optional, type=long
;       color of text
;    delimiter : in, optional, type=string, default='  '
;       text to include between names and printed values
;    _extra : in, optional, type=keywords
;       keywords to PLOT, PLOTS, and XYOUTS
;-
pro mg_slopegraph, names, startValues, endValues, $
                   start_title=startTitle, end_title=endTitle, $
                   title=title, $
                   line_color=lineColor, $
                   value_format=valueFormat, $
                   text_color=textColor, $
                   delimiter=delimiter, $
                   _extra=e
  compile_opt strictarr

  _delimiter = n_elements(delimiter) eq 0L ? '  ' : delimiter

  minValue = min(startValues) < min(endValues)
  maxValue = max(startValues) > max(endValues)

  ; define coordinate system
  plot, [0., 1.], [minValue, maxValue], xstyle=5, ystyle=5, /nodata, $
        position=[0.35, 0.05, 0.65, 0.85], $
        _extra=e

  origin = convert_coord(0.0, minValue, /data, /to_device)
  charHeight = convert_coord(0, origin[1] + !d.y_ch_size, /device, /to_data)
  charHeight = charHeight[1] - minValue
  lineHeight = charHeight * 1.3

  gap = 0.05

  _startValues = mg_slopegraph_spread(startValues, charHeight, lineHeight)
  _endValues = mg_slopegraph_spread(endValues, charHeight, lineHeight)

  ; TODO: should use a force directed layout when it is more tuned
  ;_startValues = mg_force(startValues, min_distance=lineHeight) - 0.3 * charHeight
  ;_endValues = mg_force(endValues, min_distance=lineHeight) - 0.3 * charHeight

  for v = 0L, n_elements(names) - 1L do begin
    plots, [0., 1.], [startValues[v], endValues[v]], color=lineColor, _extra=e

    xyouts, 0. - gap, _startValues[v], $
            names[v] + _delimiter + string(startValues[v], format=valueFormat), $
            alignment=1.0, color=textColor, _extra=e
    xyouts, 1. + gap, _endValues[v], $
            string(endValues[v], format=valueFormat) + _delimiter + names[v], $
            alignment=0.0, color=textColor, _extra=e
  endfor

  if (n_elements(startTitle) gt 0L) then begin
    xyouts, 0. - gap, maxValue + 1.5 * lineHeight, startTitle, $
            alignment=1.0, _extra=e
  endif

  if (n_elements(endTitle) gt 0L) then begin
    xyouts, 1. + gap, maxValue + 1.5 * lineHeight, endTitle, $
            alignment=0.0, _extra=e
  endif

  if (n_elements(title) gt 0L) then begin
    xyouts, 0.5, 0.95, title, /normal, alignment=0.5, _extra=e
  endif
end

; main-level example programs

countries = ['Sweden', 'Netherlands', 'Norway', 'Britain', 'France', $
             'Germany', 'Belgium', 'Canada', 'Finland', 'Italy', $
             'United States', 'Greece', 'Switzerland', 'Spain', 'Japan']

receipts = [[46.9, 57.4], $
            [44.0, 55.8], $
            [43.5, 52.2], $
            [40.7, 39.0], $
            [39.0, 43.4], $
            [37.5, 42.9], $
            [35.2, 43.2], $
            [35.2, 35.8], $
            [34.9, 38.2], $
            [30.4, 35.7], $
            [30.3, 32.5], $
            [26.8, 30.6], $
            [26.5, 33.2], $
            [22.5, 27.1], $
            [20.7, 26.6]]

title = 'Current Receipts of Goverment as a Percentage of GDP'

startValues = reform(receipts[0, *])
endValues = reform(receipts[1, *])

title = strjoin(mg_grstrwrap(title, 200), '!C')

if (keyword_set(png)) then begin
  mg_psbegin, /image, filename='receipts.ps', xsize=4.5, ysize=8, /inches
  device, set_font='Times', /tt_font
  font = 1
  delimiter = '    '
endif else begin
  window, /free, xsize=400, ysize=700, title='Slopegraph'
  font = -1
  delimiter = '  '
endelse

mg_slopegraph, countries, startValues, endValues, title=title, $
               start_title='1970', end_title='1979', $;, line_color='00ffff'x, $
               value_format='(F5.2)', delimiter=delimiter, font=font

if (keyword_set(png)) then begin
  mg_psend
  mg_convert, 'receipts', /from_ps, /to_png, scale=25, output=im
  file_delete, 'receipts.ps'
  file_delete, 'receipts.png'
  window, /free, xsize=338, ysize=600, title='Slopegraph'
  tvscl, im, true=1
endif

end