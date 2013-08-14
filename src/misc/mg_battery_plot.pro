; docformat = 'rst'


function mg_battery_plot_extract, line
  compile_opt strictarr

  tokens = stregex(line, '.* = ([[:digit:]]+)', /extract, /subexpr)
  return, tokens[1] eq '' ? -1L : long(tokens[1])
end


pro mg_battery_plot
  compile_opt strictarr

  filename = '~/data/battery.log'
  nlinesPerReading = 5L

  nlines = file_lines(filename)
  nreadings = nlines / nlinesPerReading

  reading = strarr(nlinesPerReading)
  times = lonarr(nreadings)
  cycle_count = lonarr(nreadings)
  max_capacity = lonarr(nreadings)
  current_capacity = lonarr(nreadings)
  design_capacity = lonarr(nreadings)

  openr, lun, filename, /get_lun
  for i = 0L, nreadings - 1L do begin
    readf, lun, reading
    times[i] = long(reading[0])
    cycle_count[i] = mg_battery_plot_extract(reading[1])
    max_capacity[i] = mg_battery_plot_extract(reading[2])
    current_capacity[i] = mg_battery_plot_extract(reading[3])
    design_capacity[i] = mg_battery_plot_extract(reading[4])
  endfor
  free_lun, lun

  cycles = uniq(cycle_count)

  plot, times, float(current_capacity) / float(max_capacity)
  for c = 0L, n_elements(cycles) - 1L do begin
    plots, fltarr(2) + times[cycles[c]], !y.crange
  endfor
end
