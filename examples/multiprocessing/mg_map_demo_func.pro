; docformat = 'rst'

;+
; Example function to be mapped over an array of values in `MG_MAP_DEMO`.
;
; Waits a random amount of time, 0.0 to 5.0 seconds, before it squares its
; input value.
;
; :Returns:
;   numeric same as `x`
;
; :Params:
;   x : in, required, type=numeric
;     input value to be squared
;-
function mg_map_demo_func, x
  compile_opt strictarr

  r = randomu(seed, 1)
  wait, 5. * r[0]

  return, x^2
end
