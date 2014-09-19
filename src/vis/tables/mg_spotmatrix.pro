; docformat = 'rst'

;+
; Create a spot matrix table.
;
; Here's a good reference for making these types of tables::
;
;   http://i-ocean.blogspot.com/2008/10/using-spots-and-rings-in-tables.html
;
; :Todo:
;   * height/width ratio needs some work
;   * there are several magic numbers: should these be calculated in some way
;     or be set through keywords?
;   * should normalize by row or column, not by the entire data matrix
;   * might need to calculate area of annulus instead of radii
;
; :Examples:
;   Run the main-level example program at the end of this file with::
;
;     IDL> .run mg_spotmatrix
;
;   This should produce:
;
;   .. image:: spotmatrix.png
;-


;+
; Make a circle, filled in proportionally to its normalized value.
;
; :Params:
;   val : in, required, type=float
;     normalized value
;   x : in, required, type=float
;     x value for center of glyph
;   y : in, required, type=float
;     y value for center of glyph
;
; :Keywords:
;   _extra : in, optional, type=keywords
;     keywords to `POLYFILL`
;-
pro mg_spotmatrix_makeglyph, val, x, y, _extra=e
  compile_opt strictarr

  r = 0.35
  t = findgen(36) * 10 * !dtor
  outsideX = r * cos(t) + x
  outsideY = r * sin(t) + y

  ; TODO: might need to do this by area instead of by radius
  insideX = r * (1. - val) * cos(t) + x
  insideY = r * (1. - val) * sin(t) + y
  polyfill, [outsideX, outsideX[0], insideX[0], reverse(insideX), outsideX[0]], $
            [outsideY, outsideY[0], insideY[0], reverse(insideY), outsideY[0]], $
            /data, _extra=e
end


;+
; Create spot matrix table.
;
; :Params:
;   data : in, required, type="fltarr(n, m)"
;     data to present in tabular format
;   colTitles : in, required, type=strarr(n)
;     column headers
;   rowTitles : in, required, type=strarr(m)
;     row headers
;
; :Keywords:
;   color : in, optional, type=integer
;     color of axes
;   title_color : in, optional, type=integer
;     color of title
;   _extra : in, optional, type=keywords
;     keywords to `PLOT`, `XYOUTS`, and/or `POLYFILL`
;-
pro mg_spotmatrix, data, colTitles, rowTitles, $
                   color=color, title_color=titleColor, _extra=e
  compile_opt strictarr

  ; normal data
  _data = data / max(data)

  ; establish coordinate system
  plot, findgen(n_elements(colTitles)), findgen(n_elements(rowTitles)), $
        /nodata, position=[0.4, 0.1, 0.95, 0.6], xstyle=5, ystyle=5, $
        color=color, _extra=e

  for col = 0L, n_elements(colTitles) - 1L do begin
    for row = 0L, n_elements(rowTitles) - 1L do begin
      mg_spotmatrix_makeglyph, _data[col, row], col, row, color=color, _extra=e
    endfor
  endfor

  xpos = convert_coord(0.05, 0.0, /normal, /to_data)
  xyouts, fltarr(n_elements(rowTitles)) + xpos[0], $
          findgen(n_elements(rowTitles)) - 0.2, $
          rowTitles, $
          /data, color=titleColor, _extra=e
  ypos = convert_coord(0.0, .7, /normal, /to_data)
  xyouts, findgen(n_elements(colTitles)), $
          fltarr(n_elements(colTitles)) + ypos[1], $
          orientation=60, $
          colTitles, $
          /data, color=titleColor, _extra=e
end


; main-level example program

dims = [400, 200]
window, /free, title='Spot matrix', xsize=dims[0], ysize=dims[1]

if (keyword_set(ps)) then begin
  mg_psbegin, /image, filename='spotmatrix.ps', $
               xsize=dims[0] / 100, ysize=dims[1] / 100, /inches
endif else begin
  device, get_decomposed=dec
  device, decomposed=0
endelse

tvlct, 168, 70, 10, 255
tvlct, 0, 0, 0, 254
tvlct, 255, 255, 255, 0

erase, 0
colTitles = ['Chicago', 'Denver', 'Boulder', 'New York', 'Los Angeles', $
             'Houston', 'Dallas', 'Boston', 'Baltimore', 'Miami']
rowTitles = ['Restaurants', 'Airports', 'Transportation', 'Air quality', 'Roads']

mg_spotmatrix, randomu(seed, 10, 5), colTitles, rowTitles, $
               background=0, color=255, title_color=254, $
               charsize=1.0

if (keyword_set(ps)) then begin
  mg_psend
  mg_convert, 'spotmatrix', max_dimension=dims, output=im
  im = bytscl(im)
  tv, im, true=1
endif else device, decomposed=dec

end
