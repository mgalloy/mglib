; docformat = 'rst'

;+
; Compute the Hermitian of the matrix, i.e., the complex conjugate of the
; transpose of the given matrix `A`. If `A` is not complex, does not take the
; conjugate so that the return value remains real.
;
; :Returns:
;   2-dimensional array of the same type as the input
;
; :Params:
;   a : in, required, type=2-dimensional numeric array
;     matrix to compute the Hermitian of
;-
function mg_hermitian, a
  compile_opt strictarr

  type = size(a, /type)
  if (type eq 6 || type eq 9) then begin
    h = conj(transpose(a))
  endif else begin
    h = transpose(a)
  endelse

  return, h
end
