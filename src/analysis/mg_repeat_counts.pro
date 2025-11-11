; docformat = 'rst'

;+
; Repeat elements of `x` by the associated element of `counts` number of times.
;
; :Examples:
;   For example, try::
;
;     IDL> x = [100.0, 200.0, 300.0]
;     IDL> counts = [3, 0, 2]
;     IDL> print, mg_repeat_counts(x, counts)
;           100.000      100.000      100.000      300.000      300.000
;
; :Returns:
;   array of the same type as `x` with sum of the counts number of elements
;
; :Params:
;   x : in, required, type=any
;     elements to be copied
;   counts : in, required, type=integer
;     number of times the associated index of `x` should be copied
;-
function mg_repeat_counts, x, counts
  compile_opt strictarr
  on_error, 2
 
  if (n_elements(x) ne n_elements(counts)) then begin
     message, 'arguments must have same number of elements'
  endif

  cumulative_counts = total(counts, /cumulative, /integer)
  result = make_array(cumulative_counts[-1], type=size(x, /type))
  for i = 0L, n_elements(x) - 1L do begin
    start_index = i - 1 lt 0 ? 0 : cumulative_counts[i - 1]
    end_index = cumulative_counts[i] - 1
    if (start_index le end_index) then result[start_index:end_index] = x[i]
  endfor

  return, result
end
