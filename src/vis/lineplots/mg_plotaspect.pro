; docformat = 'rst'

;+
; Calculates the optimal aspect ratio for a plot of the given values. The best
; aspect ratio will make most lines slope at about 45 degrees so that
; anomolies are more easily spotted.
;
; :Categories:
;    graphics computation
;-

;+
; Calculate aspect ratio for a plot.
;
; :Returns:
;    float
;
; :Params:
;    x : in, required, type=fltarr
;       x-values of plot if y-values present, otherwise y-values of plot
;    y : in, optional, type=fltarr
;       y-values of plot
;-
function mg_plotaspect, x, y
  compile_opt strictarr

  meanAbsSlope = mean(abs(n_params() eq 1L ? deriv(x) : deriv(x, y)))

  case n_params() of
    1: begin
        xrange = n_elements(x) - 1L
        yrange = max(x, min=ymin) - ymin
      end
    2: begin
        xrange = max(x, min=ymin) - ymin
        yrange = max(y, min=ymin) - ymin
      end
  endcase

  displaySlope = (xrange / yrange) * meanAbsSlope

  return, displaySlope
end