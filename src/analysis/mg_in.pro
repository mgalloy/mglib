; docformat = 'rst'

;+
; Returns whether an element in contained in an array.
;
; :Examples:
;    Try::
;
;       IDL> arr = ['a', 'b', 'd', 'f', 'g']
;          1
;       IDL> print, mg_in(arr, 'c')
;          0
; :Returns:
;    byte
;
; :Params:
;    arr : in, required, type=array
;       array to check for membership of `el`
;    el : in, required, type=any
;       element to check for membership in `arr`
;-
function mg_in, arr, el
  compile_opt strictarr

  return, ~array_equal(arr eq el, 0B)
end
