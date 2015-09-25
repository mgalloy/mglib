; docformat = 'rst'

;+
; Insert gaps into data if the `x` values are farther than
; `MIN_GAP_LENGTH` apart.
;
; :Params:
;   x : in, required, type=numeric array
;     x values
;   y : in, required, type=numeric array
;     y values
;
; :Keywords:
;   min_gap_length : in, optional, type=numeric, default=10
;     intervals with x values farther apart than this value with have
;     a gap inserted in them
;   gap_value : in, optional, type=numeric, default=f_nan
;     value to use for gaps
;   x_out : out, optional, type=numeric array
;     output `x` values with gaps 
;   y_out : out, optional, type=numeric array
;     output `y` values with gaps 
;-
pro mg_add_gaps, x, y, min_gap_length=min_gap_length, $
                 gap_value=gap_value, $
                 x_out=x_out, y_out=y_out
  compile_opt strictarr

  _min_gap_length = n_elements(min_gap_length) eq 0L ? 10.0 : min_gap_length
  _gap_value = n_elements(gap_value) eq 0L ? !values.f_nan : gap_value

  n = n_elements(x)
  diffs = x[1:*] - x[0:-1]
  ind = where(diffs gt _min_gap_length, count)
  if (count gt 0L) then begin
    x_out = make_array(n + count, type=size(x, /type))
    y_out = make_array(n + count, type=size(y, /type))

    ind = [-1, ind, n - 1L]

    for c = 1L, count + 1L do begin
      x_out[ind[c - 1L] + c:ind[c] + c - 1L] = x[ind[c - 1L] + 1:ind[c]]
      y_out[ind[c - 1L] + c:ind[c] + c - 1L] = y[ind[c - 1L] + 1:ind[c]]
      if (c ne count + 1L) then begin
        x_out[ind[c] + c] = _gap_value
        y_out[ind[c] + c] = _gap_value
      endif
    endfor
  endif else begin
    x_out = x
    y_out = y
  endelse
end
