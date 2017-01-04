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
;       keywords to `PLOT`, `MG_HISTPLOT`, or `HISTOGRAM` routines
;-
pro mg_scatterplot_matrix, data, column_names=column_names, psym=psym, _extra=e
  compile_opt strictarr

  _psym = n_elements(psym) eq 0L ? 3 : psym
  dims = size(data, /dimensions)

  orig_pmulti = !p.multi
  !p.multi = [0, dims[0], dims[0]]

  for row = 0L, dims[0] - 1L do begin
    for col = 0L, dims[0] - 1L do begin
      if (col eq row) then begin
        mg_histplot, histogram(data[row, *], _extra=e), /fill, _extra=e
      endif else begin
        plot, data[row, *], data[col, *], psym=_psym, $
              xtitle=column_names[col], ytitle=column_names[row], $
              _extra=e
      endelse
    endfor
  endfor

  !p.multi = orig_pmulti
end


; main-level example program

ps = 0

mg_constants

m = 4
n = 40

if (keyword_set(ps)) then mg_psbegin, filename='scatterplot_matrix.ps'
mg_window, xsize=10, ysize=10, /inches, title='mg_scatterplot_matrix example'

data = randomu(seed, m, n)

mg_scatterplot_matrix, data, $
                       psym=!mg.psym.diamond, charsize=2.0, symsize=0.6, $
                       nbins=10, $
                       column_names=['A', 'B', 'C', 'D']

if (keyword_set(ps)) then begin
  mg_psend
  mg_convert, 'scatterplot_matrix', max_dimension=[1000, 1000], output=im
  mg_image, im, /new_window
endif

end
