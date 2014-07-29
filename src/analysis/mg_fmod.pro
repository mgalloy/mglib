; docformat = 'rst'

;+
; Return the modulus of floating point values.
;
; :Examples:
;   With periodic values such as angles, it is useful to calculate the floating
;   point modulus of the values. For example::
;
;     n = 10L
;     angles = 1000.0 * (randomu(seed, n) - 0.5)
;     period = 2.0 * !pi
;     rotations = floor(angles / period)
;     phase = mg_fmod(angles, period)
;
; :Returns:
;   numeric scalar/array
;
; :Params:
;   x : in, required, type=numeric
;     values
;   y : in, required, type=scalar numeric
;     modulus
;-
function mg_fmod, x, y
  compile_opt strictarr

  return, ((x mod y) + y) mod y
end


; main-level example

n = 10L
angles = 1000.0 * (randomu(seed, n) - 0.5)
period = 2.0 * !pi
rotations = floor(angles / period)
phase = mg_fmod(angles, period)

for i = 0L, n - 1L do print, angles[i], rotations[i], phase[i]

end

