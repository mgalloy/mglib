; docformat = 'rst'

;+
; Create a set of data points that cluster into `n` blobs.
;
; :Returns:
;   fltarr(n_dimensions, total(sizes))
;
; :Params:
;   n : in, required, type=integer
;     number of blobs to make
;
; :Keywords:
;   n_dimensions : in, optional, type=integer, default=2
;     number of dimensions
;   sizes : in, optional, type=lonarr, default=50
;     number of points in each blob, either an array of sizes or a scalar
;     giving the size of all blobs
;   scales : in, optional, type=fltarr, default=1.0
;     scale factor for each blob, either an array of scales or a scalar giving
;     the scale for all blobs
;   centers : in, optional, type="fltarr(n_dimensions, n)"
;     centers of the blobs, picked at random if not specified
;   seed : in, out, optional, type=integer
;     random number generator seed
;-
function mg_make_blobs, n, $
                        n_dimensions=n_dimensions, $
                        sizes=sizes, $
                        scales=scales, $
                        centers=centers, $
                        seed=seed
  compile_opt strictarr

  _n_dimensions = mg_default(n_dimensions, 2)

  case n_elements(sizes) of
    0: _sizes = lonarr(n) + 50L
    1: _sizes = lonarr(n) + sizes[0]
    else: _sizes = sizes
  endcase

  case n_elements(scales) of
    0: _scales = fltarr(n) + 1.0
    1: _scales = fltarr(n) + scales[0]
    else: _scales = scales
  endcase

  if (n_elements(centers) eq 0L) then begin
    _centers = randomu(seed, _n_dimensions, n)
    _centers *= 10.0 * rebin(reform(_scales, 1, n), _n_dimensions, n)
  endif else begin
    _centers = centers
  endelse

  blobs = fltarr(_n_dimensions, total(_sizes, /integer))
  current_index = 0L
  for b = 0L, n - 1L do begin
    blob = _scales[b] * randomn(seed, _n_dimensions, _sizes[b])
    blob += rebin(reform(_centers[*, b], _n_dimensions, 1), _n_dimensions, _sizes[b])
    blobs[0, current_index] = blob
    current_index += _sizes[b]
  endfor

  return, blobs
end


; main-level example program

blobs = mg_make_blobs(3, $
                      sizes=50, $
                      scales=0.5, $
                      centers=[[7.5, 8.0], [3.0, 6.0], [5.5, 3.0]])

window, xsize=400, ysize=400, /free, title='Blobs'
plot, blobs[0, *], blobs[1, *], psym=1, $
      xrange=[0.0, 10.0], xstyle=1, $
      yrange=[0.0, 10.0], ystyle=1

end
