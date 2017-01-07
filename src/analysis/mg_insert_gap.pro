; docformat = 'rst'

;+
; Insert values into an array at the given locations.
;
; :Returns:
;   new `y` values
;
; :Params:
;   x : in, required, type=numeric array
;     independent values to insert a value from `values` into, must be
;     monotonically increasing
;   y : in, required, type=numeric array
;     dependent values to insert a gap into
;   values : in, required, type=numeric array
;     `x` locations to insert gap values at
;
; :Keywords:
;   new_x : out, optional, type=numeric array
;     new `x` values
;   locations : out, optional, type=lonarr
;     index locations of new values
;   min_gap_length : in, optional, type=float
;     insert NaN for gaps in x-axis values larger than this value
;   gap_value : in, optional, type=float, default=!values.f_nan
;     value to insert
;-
function mg_insert_gap, x, y, values, new_x=new_x, locations=locations, $
                        min_gap_length=min_gap_length, $
                        gap_value=gap_value
  compile_opt strictarr

  _gap_value = mg_default(gap_value, !value.f_nan)

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
      new_y[new_loc] = _gap_value
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

  if (n_elements(min_gap_length) gt 0L) then begin
    diff = new_x[1:*] - new_x[0:-2]
    ind = where(abs(diff) gt abs(min_gap_length), count)
    if (count gt 0L) then begin
      gap_values = ((new_x[1:*])[ind] + (new_x[0:-2])[ind]) / 2.0
      _new_y = mg_insert_nan(new_x, new_y, gap_values, $
                             new_x=_new_x, $
                             locations=new_locations, $
                             gap_value=_gap_value)
      new_x = _new_x
      new_y = _new_y

      ; merge new_locations into locations
      _locations = lonarr(n_elements(locations) + n_elements(new_locations))
      i = 0
      j = 0
      pos = 0
      while (i lt n_elements(locations) || j lt n_elements(new_locations)) do begin
        if (i ge n_elements(locations)) then begin
          _locations[pos++] = new_locations[j++]
        endif else if (j ge n_elements(new_locations)) then begin
          _locations[pos++] = locations[i++] + j
        endif else if (locations[i] lt new_locations[j]) then begin
          _locations[pos++] = locations[i++] + j
        endif else begin
          _locations[pos++] = new_locations[j++]
        endelse
      endwhile
      locations = _locations
    endif
  endif

  return, new_y
end


; main-level example program

x = findgen(10)
y = 2.0 * findgen(10)

new_y = mg_insert_gap(x, y, [-1.0, -0.5, 1.5, 8.8, 8.9, 9.5, 10.0], new_x=new_x)
print, new_x
print, new_y

end
