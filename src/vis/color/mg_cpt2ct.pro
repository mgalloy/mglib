; docformat = 'rst'

;+
; Converts a GMT color table file to an RGB color table.
;
; :Examples:
;    For example, if the GMT color tables files were stored in the `cpt`
;    directory::
;
;       IDL> tvlct, mg_cpt2ct('gmt/GMT_relief')
;
; :Returns:
;    bytarr(256, 3)
;
; :Params:
;    filename : in, required, type=string
;       filename of GMT color table file, i.e., `.cpt` file; if filename is
;       not found then assumed to be in the `cpt-city` catalog
;
; :Keywords:
;    name : out, optional, type=string
;       color table name
;-
function mg_cpt2ct, filename, name=name
  compile_opt strictarr
  on_error, 2

  _filename = file_test(filename) $
                ? filename $
                : filepath(filename, subdir=['cpt-city'], root=mg_src_root())

  if (~file_test(_filename)) then begin
    message, string(filename, format='(%"cpt file %s not found")')
  endif

  nlines = file_lines(_filename)
  lines = strarr(nlines)
  openr, lun, _filename, /get_lun
  readf, lun, lines
  free_lun, lun

  colorModel = 'RGB'
  matches = ''
  i = 0
  while (matches[0] eq '' && strmid(lines[i], 0, 1) eq '#') do begin
    matches = stregex(lines[i++], '^# COLOR_MODEL = ([+HSVRGB]*)', /subexpr, /extract)
    if (matches[0] ne '') then colorModel = matches[1]
  endwhile

  dataLines = stregex(lines, '^[[:space:]]*[-[:digit:]]', /boolean)
  dataLinesInd = where(dataLines eq 1B, count)

  data = fltarr(8, count)
  for i = 0L, count - 1L do begin
    data[*, i] = float((strsplit(lines[dataLinesInd[i]], /extract))[0:7])
  endfor

  minValue = data[0, 0]
  maxValue = data[4, count - 1]

  cutoffs = value_locate([reform(data[0, *]), data[4, count - 1L]], $
                         (maxValue - minValue) * findgen(256) / 255. + minValue)

  ncolors = histogram(cutoffs < (count - 1L))

  result = bytarr(256, 3)
  pos = 0L
  for i = 0L, count - 1L do begin
    c1 = reform(data[1:3, i])
    c2 = reform(data[5:7, i])

    if (ncolors[i] gt 0) then begin
      colors = congrid(transpose([[c1], [c2]]), ncolors[i], 3, /interp, /minus_one)

      if (colorModel eq 'HSV' || colorModel eq '+HSV') then begin
        color_convert, colors[*, 0], colors[*, 1], colors[*, 2], r, g, b, /hsv_rgb
        colors[*, 0] = r
        colors[*, 1] = g
        colors[*, 2] = b
      endif

      result[pos, 0] = colors
    endif

    pos += ncolors[i]
  endfor

  name = stregex(file_basename(_filename), 'GMT_([_[:alnum:]]*).cpt', /subexpr, /extract)
  if (name[0] eq '') then name = stregex(file_basename(_filename), '([_[:alnum:]]*).cpt', /subexpr, /extract)
  name = name[1]

  return, result
end


; main-level program used to create gmt.tbl

; cd, 'cpt-city', current=wd
; files = file_search('.', '*.cpt', count=nfiles)
; mg_create_ctfile, '../gmt.tbl'
; for f = 0B, nfiles - 1L do begin
;   rgb = mg_cpt2ct(files[f], name=ctname)
;   print, ctname, format='(%"adding %s")'
;   modifyct, f, ctname, reform(rgb[*, 0]), reform(rgb[*, 1]), reform(rgb[*, 2]), file='../gmt.tbl'
; endfor
; cd, wd

elev = read_binary(file_which('elevbin.dat'), data_dims=[64, 64], data_type=1)
elev = rebin(elev, 64 * 8, 64 * 8)

tvlct, mg_cpt2ct('ngdc/ETOPO1.cpt')
mg_decomposed, 0, old_decomposed=odec

mg_image, read_image(file_which('elev_t.jpg')), /new_window
mg_image, mg_scaleimage(elev, dividers=[0, 1, 256], outputs=[0, 144, 256]), $
          /new_window

mg_decomposed, odec

end