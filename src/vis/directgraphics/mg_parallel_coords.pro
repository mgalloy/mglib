; docformat = 'rst'

;+
; Parallel coordinates implementation. For more information about parallel
; coordinates, see `Eager Eyes' <http://eagereyes.org/parallel-sets>` 
; description.
;
; :Examples:
;    Try the main-level program at the end of this file to show an example of
;    parallel coordinates::
; 
;       IDL> .run mg_parallel_coords
;
;    This should produce something like:
;
;    .. image:: obesity.png
;-

;+
; Display a parallel coordinate graph.
; 
; :Params:
;    data : in, required, type="fltarr(m, n)"
;       data to plot: m dimensions by n data elements
;
; :Keywords:
;    dimension_titles : in, optional, type=strarr(m)
;       titles for the dimensions displayed below the x-axis
;    data_title : in, optional, type=string
;       y-axis title
;    axes_color : in, optional, type=color
;       color of the axes, not including the leftmost axes with labels
;    color : in, optional, type=lonarr(n)
;       array of color values for the various data elements, if less than
;       n elements are specified will cycle through the values
;    psym : in, optional, type=lonarr(n)
;       array of symbol values for the various data elements, if less than
;       n elements are specified will cycle through the values
;    linestyle : in, optional, type=lonarr(n)
;       array of linestyle values for the various data elements, if less than
;       n elements are specified will cycle through the values
;    overplot : in, optional, type=boolean
;       set to skip plotting axes
;    nodata : in, optional, type=boolean
;       set to skip plotting data
;    _extra : in, optional, type=keywords
;       keywords to PLOT, AXIS, XYOUTS, and OPLOT
;-
pro mg_parallel_coords, data, $
                        dimension_titles=dimensionTitles, data_title=dataTitle, $
                        axes_color=axesColor, $
                        color=color, psym=psym, linestyle=linestyle, $
                        overplot=overplot, nodata=nodata, _extra=e
  compile_opt strictarr
  
  dims = size(data, /dimensions)
  range = mg_range(data)
  
  _color = n_elements(color) eq 0L ? 255B : color
  ncolors = n_elements(_color)

  _linestyle = n_elements(linestyle) eq 0L ? 0B : linestyle
  nlinestyle = n_elements(_linestyle)

  _psym = n_elements(psym) eq 0L ? 0B : psym
  npsym = n_elements(_psym)
  
  ; plot axes
  if (~keyword_set(overplot)) then begin
    plot, [0, dims[0] - 1L], range, /nodata, $
          xstyle=5, ytick_get=ytickvalues, ytitle=dataTitle, $
          _extra=e
    for dim = 0L, dims[0] - 1L do begin
      if (dim ne 0L) then begin
        axis, dim, range[0], yaxis=0, ystyle=1, $
              ytickname=replicate(' ', n_elements(ytickvalues)), $
              color=axesColor, $
              _extra=e
      endif
      if (dim lt n_elements(dimensionTitles)) then begin
        xyouts, dim, ytickvalues[0], '!C' + dimensionTitles[dim], $
                alignment=0.5, $
                _extra=e
      endif
    endfor
  endif

  ; plot dimensions
  if (~keyword_set(nodata)) then begin
    for row = 0L, dims[1] - 1L do begin
      oplot, lindgen(dims[0]), data[*, row], $
             color=_color[row mod ncolors], $
             linestyle=_linestyle[row mod nlinestyle], $
             psym=_psym[row mod npsym], $
             _extra=e
    endfor
  endif
end


; main-level example

lines = strarr(9)
openr, lun, filepath('obesity-rates-decades.csv', root=mg_src_root()), /get_lun
readf, lun, lines
free_lun, lun

cohorts = (strsplit(lines[0], ',', /extract))[1:*]
data = fltarr(8, 8)
ages = strarr(8)

for row = 0L, 7L do begin
  lineTokens = strsplit(lines[row + 1L], ',', /preserve_null, /extract)
  ages[row] = lineTokens[0]
  
  missingDataInd = where(lineTokens eq '', count)
  data[*, row] = float(lineTokens[1:*])
  if (count gt 0L) then data[missingDataInd + row * 8L - 1L] = !values.f_nan
endfor

data = transpose(data)

mg_psbegin, filename='obesity.ps', xsize=6, ysize=4, /inches, /image
mg_decomposed, 1, old_decomposed=old_decomposed
device, set_font='Helvetica', /tt_font

mg_parallel_coords, data, /nodata, $
                    position=[0.1, 0.1, 0.9, 0.85], $
                    thick=0.5, ticklen=0, charsize=0.9, $
                    axes_color=mg_rgb2index([200, 200, 200]), $                     
                    dimension_titles=ages, data_title='% obese'

xyouts, 0.5, 0.925, '% obese by age cohort', /normal, alignment=0.5

mg_decomposed, 0
mg_loadct, cpt_filename='cw/2/cw2-066.cpt'

colors = bytscl(bindgen(8))
mg_parallel_coords, data, /overplot, $
                    thick=10, $
                    color=colors, $
                    psym=[1, 0, 0, 0, 0, 0, 0, 0]
                     
cohorts = ['1996-2005', '1986-1995', '1976-1985', '1966-1975', '1956-1965', $
           '1946-1955', '1936-1945', '1926-1935']
tvlct, r, g, b, /get
colors = mg_rgb2index([[r[colors]], [g[colors]], [b[colors]]])
mg_decomposed, 1

mg_legend, position=[0.685, 0.2, 0.885, 0.6], $
           item_name=cohorts, $
           item_thick=lonarr(8) + 10., $
           line_height=0.4, $
           line_length=0.15, $
           item_color=colors, $
           gap=0.2, $
           background='f0f0f0'x

mg_decomposed, old_decomposed
mg_psend

mg_convert, 'obesity', max_dimensions=[800, 600], output=im
mg_image, im, /new_window

end
                         