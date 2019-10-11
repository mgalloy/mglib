; docformat = 'rst'

;+
; See https://www.johndcook.com/blog/2019/10/08/harmonographs/
;-
function mg_harmonograph, f1, f2, d1, d2, t, phi1=phi1, phi2=phi2
  compile_opt strictarr

  x = cos(f1 * t + mg_default(phi1, 0.0)) * exp(-d1 * t)
  y = cos(f2 * t + mg_default(phi2, 0.0)) * exp(-d2 * t)

  return, [[x], [y]]
end


; main-level example program

n = 10000L
t = 100.0 * findgen(n) / (n - 1)  ; 0.0 ... 100.0
coords = mg_harmonograph(3, 4, 0.01, 0.02, t, phi1=0.0, phi2=sqrt(2))

window, xsize=1000, ysize=1000
plot, coords[*, 0], coords[*, 1], $
      xstyle=5, ystyle=5, xrange=[-1.0, 1.0], yrange=[-1.0, 1.0]

end
