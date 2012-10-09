; docformat = 'rst'

;+
; Generates 1/f^a noise. By default, it generates 1/f noise i.e. pink noise.
;
; :Examples:
;    This generates pink noise::
;
;       tvscl, mg_pinknoise(512, 256)
;
;    Pink noise looks like:
;
;    .. image:: pink-noise-1_0.png
;
;    Other 1/f^a noise can be generated using the POWER keyword::
;
;       tvscl, mg_pinknoise(512, 256, power=1.8)
;
;    This noise looks like:
;
;    .. image:: pink-noise-1_8.png
;
;    For POWER=2.4:
;
;    .. image:: pink-noise-2_4.png
;
; :Returns:
;    dblarr(m, n)
;
; :Params:
;    m : in, required, type=long
;       size of first dimension
;    n : in, required, type=long
;       size of second dimension
;
; :Keywords:
;    power : in, optional, type=double, default=1.0
;       the a in 1/f^a noise
;-
function mg_pinknoise, m, n, power=p
  compile_opt strictarr

  ; default power is 1.0 i.e. pink noise
  _p = n_elements(p) eq 0L ? 1.0D : p

  r = fft(randomu(seed, m, n), /double)

  ; apply filter
  f = r / (shift(dist(m, n), m / 2, n / 2) > 1d-4) ^ _p

  f = abs(fft(f, /inverse, /double))

  scaled = (f - min(f)) / (max(f) - min(f))

  return, scaled
end


; main-level example program

window, /free, xsize=512, ysize=256*3, title='1/f^a noise'

tvscl, mg_pinknoise(512, 256), 0
tvscl, mg_pinknoise(512, 256, power=1.8), 1
tvscl, mg_pinknoise(512, 256, power=2.4), 2

end
