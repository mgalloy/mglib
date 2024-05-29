; docformat = 'rst'

;+
; Create a color table based on starting and ending colors (or optionally, a
; center color) and linearly interpolating.
;
; :Examples:
;   See the main-level example program::
;
;     IDL> .run mg_makect
;
;   It produces:
;
;   .. image:: colortables.png
;
; :Returns:
;   `bytarr(n, 3)`
;
; :Params:
;   c1 : in, required, type="bytarr(3) or bytarr(m, 3)"
;     starting color or bytarr(m, 3) of colors; must be bytarr(m, 3) if
;     `PARTITION` keyword is used
;   c2 : in, optional, type=bytarr(3)
;     if two parameters are passed in, this is the ending color; if three
;     parameters are passed in, this is the center color
;   c3 : in, optional, type=bytarr(3)
;     ending color
;
; :Keywords:
;   ncolors : in, optional, type=long, default=256
;     number of colors in the color table to create
;   partition : in, optional, type=fltarr(m - 1)
;     set to create a color table by interpreting c1 as a `bytarr(m, 3)`
;     list of colors and the value of `PARTITION` as a `fltarr(k)` list of
;     cutoff values between 0.0 and 1.0 (or 0 and 255); there must be one
;     more color than cutoff value provided
;-
function mg_makect, c1, c2, c3, $
                    ncolors=ncolors, $
                    partition=partition, $
                    indices=indices, $
                    lab=lab
  compile_opt strictarr
  on_error, 2

  _ncolors = n_elements(ncolors) eq 0L ? 256L : ncolors

  switch n_params() of
    3: _c3 = keyword_set(lab) ? mg_rgb2lab(c3) : c3
    2: _c2 = keyword_set(lab) ? mg_rgb2lab(c2) : c2
    1: _c1 = keyword_set(lab) ? mg_rgb2lab(c1) : c1
  endswitch

  if (n_elements(indices) gt 0L) then begin
    r = fltarr(indices[-1] - indices[0] + 1L)
    g = fltarr(indices[-1] - indices[0] + 1L)
    b = fltarr(indices[-1] - indices[0] + 1L)
    for group = 0L, n_elements(indices) - 2L do begin
      n = indices[group + 1L] - indices[group] + 1L
      r[indices[group]:indices[group + 1]] = ((float(_c1[group + 1, 0]) - float(_c1[group, 0])) * findgen(n) / (n - 1L) + _c1[group, 0])
      g[indices[group]:indices[group + 1]] = ((float(_c1[group + 1, 1]) - float(_c1[group, 1])) * findgen(n) / (n - 1L) + _c1[group, 1])
      b[indices[group]:indices[group + 1]] = ((float(_c1[group + 1, 2]) - float(_c1[group, 2])) * findgen(n) / (n - 1L) + _c1[group, 2])
    endfor
  endif else if (n_elements(partition) gt 0L) then begin
    type = size(partition, /type)

    cutoffs = (type eq 4 || type eq 5) ? bytscl([0., partition, 1.]) : partition
    ind = value_locate(cutoffs, bindgen(256))

    r = (c1[*, 0])[ind]
    g = (c1[*, 1])[ind]
    b = (c1[*, 2])[ind]
  endif else begin
    case n_params() of
      0: message, 'incorrect number of parameters'
      1: begin
          ndims = size(_c1, /n_dimensions)
          if (ndims ne 2L) then message, '1 argument must be 2-dimensional'
          dims = size(_c1, /dimensions)
          if (dims[1] ne 3L) then message, '1 argument must be m by 3'

          r = congrid(reform(_c1[*, 0]), _ncolors, /interp, /minus_one)
          g = congrid(reform(_c1[*, 1]), _ncolors, /interp, /minus_one)
          b = congrid(reform(_c1[*, 2]), _ncolors, /interp, /minus_one)
        end
      2: begin
          r = ((float(_c2[0]) - float(_c1[0])) * findgen(_ncolors) / (_ncolors - 1L) + _c1[0])
          g = ((float(_c2[1]) - float(_c1[1])) * findgen(_ncolors) / (_ncolors - 1L) + _c1[1])
          b = ((float(_c2[2]) - float(_c1[2])) * findgen(_ncolors) / (_ncolors - 1L) + _c1[2])
        end
      3: begin
          r = congrid([_c1[0], _c2[0], _c3[0]], _ncolors, /interp, /minus_one)
          g = congrid([_c1[1], _c2[1], _c3[1]], _ncolors, /interp, /minus_one)
          b = congrid([_c1[2], _c2[2], _c3[2]], _ncolors, /interp, /minus_one)
        end
    endcase
  endelse

  rgb = [[r], [g], [b]]

  if (keyword_set(lab)) then rgb = mg_lab2rgb(rgb)

  rgb = byte(rgb)

  return, rgb
end


; main-level example program

tvlct, oldRGB, /get
mg_decomposed, 0, old_decomposed=odec

xsize = 256
ysize = 20

window, /free, xsize=xsize, ysize=5 * ysize, title='Example color tables'

tvlct, mg_makect(mg_color('yellow'), mg_color('blue'))
tv, bindgen(xsize) # (bytarr(ysize) + 1B), 0

tvlct, mg_makect(mg_color('yellow'), mg_color('blue'), ncolors=16)
tv, bytscl(bindgen(xsize), top=15) # (bytarr(ysize) + 1B), 1

tvlct, mg_makect([255, 255, 255], [255, 0, 0])
tv, bindgen(xsize) # (bytarr(ysize) + 1B), 2

tvlct, mg_makect(mg_color('red'), mg_color('white'), mg_color('green'), $
                  ncolors=32)
tv, bytscl(bindgen(xsize), top=31) # (bytarr(ysize) + 1B), 3

tvlct, mg_makect(mg_color('powderblue'), mg_color('ivory'), mg_color('sienna'), $
                  ncolors=16)
tv, bytscl(bindgen(xsize), top=15) # (bytarr(ysize) + 1B), 4

filename = file_which('convec.dat')
convec = bytarr(248, 248)
openr, lun, filename, /get
readu, lun, convec
free_lun, lun
tvlct, mg_makect(mg_color(['white','green','yellow','blue','red']), partition=[0.2, 0.3, 0.5, 0.8])
mg_image, convec, /new_window

colors = ['blue', 'white', 'sienna', 'forestgreen', 'silver']
ct = mg_makect(mg_color(colors), indices=[0, 50, 75, 175, 255])
tvlct, ct
mg_image, bytscl(findgen(512)) # (bytarr(40) + 1B), /new_window, $
          title=string(strjoin(colors, ', '), format='%s')

mg_image, convec, /new_window

colors = ['blue', 'white', 'sienna', 'forestgreen', 'silver']
tvlct, mg_makect(mg_color(colors), indices=[0, 75, 150, 200, 255], /lab)
mg_image, bytscl(findgen(512)) # (bytarr(40) + 1B), /new_window, $
          title=string(strjoin(colors, ', '), format='%s - through Lab')

colors = ['red', 'white', 'blue']
n_colors = 31
tvlct, mg_makect(mg_color(colors), indices=[0, 128, 255], ncolors=n_colors, /lab)
mg_image, bytscl(findgen(512), top=n_colors - 1L) # (bytarr(40) + 1B), /new_window, $
          title=string(strjoin(colors, ', '), format='%s - through Lab')

mg_decomposed, odec
tvlct, oldRGB

end
