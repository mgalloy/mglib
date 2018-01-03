; docformat = 'rst'

;+
; Computes the local moments for an array with a given window size.
;
; :Examples:
;    Try the main-level example program at the end of this file::
;
;       IDL> .run mg_local_moment
;
; :Returns:
;    array of the same size as `image` input parameter, type will be float or
;    double depending on the type of `image` and if the `DOUBLE` keyword is
;    set
;
; :Params:
;    image : in, required, type=numeric array
;       original image; will be converted to float or double
;    width : in, required, type=integer
;       size of window
;
; :Keywords:
;    double : in, optional, type=boolean
;       set to do computations as doubles
;    sdev : out, optional, type=float/double array
;       set to a named variable to get local standard deviation
;    variance : out, optional, type=float/double array
;       set to a named variable to get local variance
;    skewness : out, optional, type=float/double array
;       set to a named variable to get local skewness
;    kurtosis : out, optional, type=float/double array
;       set to a named variable to get local kurtosis
;    edge_mirror : in, optional, type=boolean
;       set to compute edge values by mirroring
;    edge_truncate : in, optional, type=boolean
;       set to compute edge values by repeating
;    edge_wrap : in, optional, type=boolean
;       set to compute edge values by padding array with zeros
;    edge_zero : in, optional, type=boolean
;       set to compute edge values by wrapping
;    nan : in, optional, type=boolean
;       set to treat NaN as missing data
;
; :Requires:
;    IDL 8.1
;-
function mg_local_moment, image, width, double=double, $
                          sdev=sdev, variance=variance, skewness=skewness, $
                          kurtosis=kurtosis, $
                          edge_mirror=edge_mirror, $
                          edge_truncate=edge_truncate, $
                          edge_wrap=edge_wrap, $
                          edge_zero=edge_zero, $
                          nan=nan
  compile_opt strictarr
  on_error, 2

  ; sanity checking on arguments
  if (n_params() ne 2) then message, 'incorrect number of arguments'

  ; convert to double precision if DOUBLE keyword is set
  _image = keyword_set(double) ? double(image) : image

  ; kernel is array of 1's with the same number of dimensions as `image`, but
  ; size in each dimension of `width`
  dims = replicate(width, size(image, /n_dimensions))
  one = fix(1, type=keyword_set(double) ? 5L : size(image, /type))
  kernel = make_array(dimension=dims, value=one)

  n = product(dims, /preserve_type)

  ; mean
  local_mean = convol(_image, kernel, $
                      edge_mirror=edge_mirror, edge_truncate=edge_truncate, $
                      edge_wrap=edge_wrap, edge_zero=edge_zero, nan=nan) / n

  ; variance or standard deviation
  if (arg_present(sdev) $
        || arg_present(variance) $
        || arg_present(skewness) $
        || arg_present(kurtosis)) then begin
    squared = convol(_image^2, kernel, $
                     edge_mirror=edge_mirror, edge_truncate=edge_truncate, $
                     edge_wrap=edge_wrap, edge_zero=edge_zero, nan=nan)
    variance = (squared  - n * local_mean^2) / (n - 1.0)
    sdev = sqrt(variance)
  endif

  ; skewness
  if (arg_present(skewness) || arg_present(kurtosis)) then begin
    cubed = convol(_image^3, kernel, $
                   edge_mirror=edge_mirror, edge_truncate=edge_truncate, $
                   edge_wrap=edge_wrap, edge_zero=edge_zero, nan=nan)
    skewness = (cubed / n - 3.0 * local_mean * squared / n + 2.0 * local_mean^3) / sdev ^ 3
  endif

  ; kurtosis
  if (arg_present(kurtosis)) then begin
    fourth = convol(_image^4, kernel, $
                    edge_mirror=edge_mirror, edge_truncate=edge_truncate, $
                    edge_wrap=edge_wrap, edge_zero=edge_zero, nan=nan)
    kurtosis = (fourth / n - 4.0 * local_mean * cubed / n + 6.0 * local_mean^2 * squared / n - 3.0 * local_mean^4) / variance^2 - 3.0
  endif

  return, local_mean
end


; main-level example program

print, '1-dimensional example: mg_local_moment(findgen(10), 3)'
print, mg_local_moment(findgen(10), 3)
print

print, '2-dimensional example: mg_local_moment(findgen(5, 5), 3)'
print, mg_local_moment(findgen(5, 5), 3)
print

print, '3-dimensional example: mg_local_moment(findgen(4, 4, 4), 3)'
print, mg_local_moment(findgen(4, 4, 4), 3)

end
