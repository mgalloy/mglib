; docformat = 'rst'

;+
; Repeats a vector `nreps` times.
;
; :Examples:
;   For example, repeat an index vector twice times::
;
;     IDL> print, mg_repeat(indgen(3), 2)
;            0       1       2       0       1       2
;
; :Returns:
;   array
;
; :Params:
;   vec : in, required, type=vector
;     vector to repeat
;   nreps : in, required, type=integer
;     number of times to repeat vector
;-
function mg_repeat, vec, nreps
  compile_opt strictarr

  nvec = n_elements(vec)
  return, reform(rebin(reform(vec, nvec, 1), nvec, nreps), nvec * nreps)
end
