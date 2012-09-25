; docformat = 'rst'

;+
; Create a matrix of scatter plots.
; 
; :Examples:
;    Try the main-level example program at the end of this file::
;
;       IDL> .run mg_scatterplot_matrix
;
;    This should produce:
;
;    .. image:: scatterplot_matrix.png
;
; :Params:
;    data : in, required, type="fltarr(m, n)"
;       m data sets of n elements each
;
; :Keywords: 
;    _extra : in, optional, type=keywords
;       keywords to PLOT routine
;-
pro mg_scatterplot_matrix, data, _extra=e
  compile_opt strictarr
  
  dims = size(data, /dimensions)
  
  orig_pmulti = !p.multi
  !p.multi = [0, dims[0], dims[0]]
  
  for row = 0L, dims[0] - 1L do begin
    for col = 0L, dims[0] - 1L do begin
      if (col ge row) then begin
        plot, data[row, *], data[col, *], _extra=e 
      endif else begin
        plot, [0, 1], [0, 1], /nodata, xstyle=5, ystyle=5
      endelse
    endfor
  endfor

  !p.multi = orig_pmulti
end


; main-level example program

m = 4
n = 20

mg_psbegin, filename='scatterplot_matrix.ps'
mg_window, xsize=4, ysize=4, /inches

data = randomu(seed, m, n)

mg_scatterplot_matrix, data, psym=4, charsize=0.6, symsize=0.5

mg_psend
mg_convert, 'scatterplot_matrix', max_dimension=[500, 500], output=im
mg_image, im, /new_window

end