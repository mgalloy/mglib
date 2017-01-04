; docformat = 'rst'

;+
; Insert NaNs into an array at the given locations.
;
; :Returns:
;   new `y` values
;
; :Params:
;   x : in, required, type=numeric array
;     independent values to insert a value from `values` into, must be
;     monotonically increasing
;   y : in, required, type=numeric array
;     dependent values to insert a NaN into
;   values : in, required, type=numeric array
;     `x` locations to insert NaN values at
;
; :Keywords:
;   new_x : out, optional, type=numeric array
;     new `x` values
;   locations : out, optional, type=lonarr
;     index locations of new values
;   gap : in, optional, type=float
;     insert NaN for gaps in x-axis values larger than this value
;-
function mg_insert_nan, x, y, values, new_x=new_x, locations=locations, gap=gap
  compile_opt strictarr

  if (n_elements(values) gt 0L) then begin
    ind = value_locate(x, values)
    locations = lonarr(n_elements(values))

    new_x = make_array(n_elements(x) + n_elements(values), type=size(x, /type))
    new_y = make_array(n_elements(y) + n_elements(values), type=size(y, /type))

    loc = 0L
    new_loc = 0L
    for i = 0L, n_elements(values) - 1L do begin
      if (ind[i] ge 0L && (loc le ind[i])) then begin
        new_x[new_loc] = x[loc:ind[i]]
        new_y[new_loc] = y[loc:ind[i]]

        new_loc += ind[i] - loc + 1L
      endif

      new_x[new_loc] = values[i]
      new_y[new_loc] = !values.f_nan
      locations[i] = new_loc

      loc = ind[i] + 1

      ++new_loc
    endfor

    if (loc lt n_elements(x)) then begin
      new_x[new_loc] = x[loc:*]
      new_y[new_loc] = y[loc:*]
    endif
  endif else begin
    new_x = x
    new_y = y
  endelse

  if (n_elements(gap) gt 0L) then begin
    diff = new_x[1:*] - new_x[0:-2]
    ind = where(abs(diff) gt abs(gap), count)
    if (count gt 0L) then begin
      gap_values = ((new_x[1:*])[ind] + (new_x[0:-2])[ind]) / 2.0
      _new_y = mg_insert_nan(new_x, new_y, gap_values, new_x=_new_x, locations=new_locations)
      new_x = _new_x
      new_y = _new_y
      locations = where(~finite(new_y))
    endif
  endif

  return, new_y
end


; main-level example program

x = findgen(10)
y = 2.0 * findgen(10)

new_y = mg_insert_nan(x, y, [-1.0, -0.5, 1.5, 8.8, 8.9, 9.5, 10.0], new_x=new_x)
print, new_x
print, new_y

end
