; docformat = 'rst'

;+
; Return the modules of floating point values.
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
x = 10.0 * (randomu(seed, n) - 0.5)
y = mg_fmod(x, 1.0)

for i = 0L, n_elements(x) - 1L do begin
  print, x[i], y[i]
endfor

end

