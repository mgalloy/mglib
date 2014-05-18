; docformat = 'rst'


; 1400386980,MaxCapacity = 9016,CurrentCapacity = 4773,DesignCapacity = 8440,CycleCount = 5

function mg_battery_plot_extract_number, s
  compile_opt strictarr
  
  tokens = stregex(s, '.* = ([[:digit:]]+)', /extract, /subexpr)
  return, tokens[1] eq '' ? -1L : long(tokens[1])
end


function mg_battery_plot_extract, line
  compile_opt strictarr

  tokens = strsplit(line, ',', /extract)

  readings = lonarr(5)
  readings[0] = long(tokens[0])
  readings[1] = mg_battery_plot_extract_number(tokens[1])
  readings[2] = mg_battery_plot_extract_number(tokens[2])
  readings[3] = mg_battery_plot_extract_number(tokens[3])
  readings[4] = mg_battery_plot_extract_number(tokens[4])

  return, readings
end


pro mg_battery_plot
  compile_opt strictarr

  filename = '~/data/battery.log'

  nlines = file_lines(filename)

  times            = lonarr(nlines)
  cycle_count      = lonarr(nlines)
  max_capacity     = lonarr(nlines)
  current_capacity = lonarr(nlines)
  design_capacity  = lonarr(nlines)

  on_ioerror, ioerror
  openr, lun, filename, /get_lun
  line = ''

  for i = 0L, nlines - 1L do begin
    readf, lun, line
    reading = mg_battery_plot_extract(line)

    times[i]            = reading[0]
    max_capacity[i]     = reading[1]
    current_capacity[i] = reading[2]
    design_capacity[i]  = reading[3]
    cycle_count[i]      = reading[4]
  endfor
  free_lun, lun

  cycles = uniq(cycle_count)

  ygap = 100
  dummy = label_date(date_format='%D %M %Z')

  mg_loadct, 27, /brewer, rgb_table=rgb

  mg_psbegin, /image, filename='battery.ps', xsize=6, ysize=4, /inches
  mg_decomposed, 1, old_decomposed=odec

  plot, mg_epoch2julian(times), current_capacity, /nodata, $
        xstyle=9, ystyle=8, xtickformat='LABEL_DATE', $
        ytitle='battery capacity (mAh)', $
        charsize=0.65, $
        position=[0.1, .1, 0.97, 0.9]

  xyouts, 0.5, 0.95, /normal, $
          'feynman battery life', $
          alignment=0.5, charsize=0.8

  oplot, mg_epoch2julian(times), current_capacity, $
         psym=mg_usersym(/circle), symsize=0.15, color=mg_rgb2index(rgb[8, *])

  for c = 0L, n_elements(cycles) - 2L do begin
    plots, fltarr(2) + mg_epoch2julian(times[cycles[c]]), !y.crange, $
           color=mg_rgb2index(rgb[3, *]), thick=4
    xyouts, mg_epoch2julian(times[cycles[c]]), !y.crange[1] + ygap, $
            string(cycle_count[cycles[c]], cycle_count[cycles[c + 1L]], $
                   format='(%"%d   %d")'), $
            alignment=0.5, color=mg_rgb2index(rgb[3, *]), charsize=0.5
  endfor

  oplot, mg_epoch2julian(times), max_capacity, $
         color=mg_rgb2index(rgb[6, *]), thick=4, linestyle=0
  xyouts, mg_epoch2julian(times[-1]), max_capacity[-1] + ygap, /data, $
          'max capacity', $
          alignment=1.0, charsize=0.6, color=mg_rgb2index(rgb[6, *])

  oplot, mg_epoch2julian(times), design_capacity, $
         thick=4, color=mg_rgb2index(rgb[8, *])
  xyouts, mg_epoch2julian(times[-1]), design_capacity[-1] + ygap, /data, $
          'design capacity', $
          alignment=1.0, charsize=0.6, color=mg_rgb2index(rgb[8, *])

  mg_decomposed, odec
  mg_psend
  mg_convert, 'battery', max_dimensions=[700, 700], output=im

  mg_image, im, /new_window
  return

  ioerror:
  print, i + 1, format='(%"error parsing line %d")'
end
