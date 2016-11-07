; docformat = 'rst'

;+
; Insert NaNs into an array at the given locations.
;
; :Returns:
;   new `y` values
;
; :Params:
;   x : in, required, type=numeric array
;     independent values to insert a value from `values` into
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
;-
function mg_insert_nan, x, y, values, new_x=new_x, locations=locations
  compile_opt strictarr

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

  x = new_x

  return, new_y
end


; main-level example program

x = findgen(10)
y = 2.0 * findgen(10)

new_y = mg_insert_nan(x, y, [-1.0, -0.5, 1.5, 8.8, 8.9, 9.5, 10.0], new_x=new_x)
print, new_x
print, new_y

end
