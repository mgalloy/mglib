; docformat = 'rst'

;+
; Stacked histogram plot.
;
; :Params:
;   x : in, optional, type=fltarr(n)
;     optional value for each bin in the histogram
;   y : in, required, type="fltarr(m, n)"
;     `m` histograms of length `n`
;
; :Keywords:
;   _extra : in, optional, type=keywords
;-
pro mg_stacked_histplot, x, y, colors=colors, _extra=e
  compile_opt strictarr
  ;on_error, 2

  case n_params() of
    0: message, 'incorrect number of parameters'
    1: begin
        y_dims = size(x, /dimensions)
        _x = findgen(y_dims[1])
        _y = x
      end
    2: begin
        y_dims = size(y, /dimensions)
        _x = x
        _y = y
      end
  endcase

  cumulative_y = total(_y, 1, /cumulative, /preserve_type)

  mg_histplot, _x, reform(cumulative_y[y_dims[0] - 1, *]), color=colors[y_dims[0] - 1], _extra=e
  for i = y_dims[0] - 2L, 0L, -1L do begin
     mg_histplot, _x, reform(cumulative_y[i, *]), color=colors[i], /overplot, _extra=e
  endfor
end

