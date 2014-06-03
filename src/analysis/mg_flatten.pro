; docformat = 'rst'

;+
; Create a 1-dimensional array from a multi-dimensional input.
;
; :Returns:
;   1-dimensional array
;
; :Params:
;   arr : in, required, type=array
;     array to flatten
;-
function mg_flatten, arr
  compile_opt strictarr

  return, reform(arr, product(size(arr, /dimensions)))
end

