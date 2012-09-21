; docformat = 'rst'

;+
; Get an RGB color value for the specified color name. The available colors
; are:
;
; .. image:: vis_colors.png
;
; :Examples:
;    For example::
;
;       IDL> print, vis_color('black')
;          0   0   0
;       IDL> print, vis_color('slateblue')
;        106  90 205
;       IDL> c = vis_color('slateblue', /index) 
;       IDL> print, c, c, format='(I, Z)'
;           13458026      CD5A6A
;       IDL> print, vis_color(['blue', 'red', 'yellow'])
;          0 255 255
;          0   0 255
;        255   0   0
;       IDL> print, vis_color(/names)
;       aliceblue antiquewhite aqua aquamarine azure beige ...
;
;    These commands are in the main-level example program::
;
;       IDL> .run vis_color
;
; :Uses:
;    vis_src_root, vis_index2rgb
;
; :Returns:
;    Returns a triple as a bytarr(3) or bytarr(3, n) by default if a single
;    color name or n color names are given. Returns a decomposed color index 
;    as a long or lonarr(n) if `INDEX` keyword is set.
; 
;    Returns a string array for the names if `NAMES` keyword is set.
;
; :Params:
;    colorname : in, required, type=string/strarr
;       case-insensitive name(s) of the color; note that both "grey" and 
;       "gray" are accepted in all names that incorporate them
;
; :Keywords:
;    names : in, optional, type=boolean
;       set to return a string of color names
;    index : in, optional, type=boolean
;       set to return a long integer with the RGB decomposed into it
;    xkcd : in, optional, type=boolean
;       set to use xkcd color survey color names instead of the HTML color
;       names (see `xkcd color survey <http://xkcd.com/color/rgb/>`)
;    crayons : in, optional, type=boolean
;       set to use crayon color names instead of the HTML color
;       names
;-
function vis_color, colorname, names=names, index=index, $
                    xkcd=xkcd, crayons=crayons
  compile_opt strictarr
  on_error, 2
  
  if (~keyword_set(names) && size(colorname, /type) ne 7) then begin
    message, 'color name must be a string'
  endif
  
  if (~keyword_set(names) && size(colorname, /n_dimensions) gt 1L) then begin
    message, 'color name must be a scalar or vector'
  endif
  
  define = { vis_color, name: '', rgb:0L }
  
  case 1 of
    keyword_set(xkcd): basename = 'xkcdcolors.dat'
    keyword_set(crayons): basename = 'crayons.dat'
    else: basename = 'htmlcolors.dat'
  endcase
  
  colorFilename = filepath(basename, root=vis_src_root())
  ncolors = file_lines(colorFilename)

  rawColors = strarr(ncolors)
  openr, lun, colorFilename, /get_lun
  readf, lun, rawColors
  free_lun, lun
  
  colors = replicate({ vis_color }, ncolors)

  for c = 0L, ncolors - 1L do begin
    space = strpos(rawColors[c], ' ')
    color = long(strmid(rawColors[c], 0L, space))
    name = strmid(rawColors[c], space + 1L)
    colors[c] = { vis_color, name: name, rgb: color }
  endfor
  
  if (keyword_set(names)) then return, colors.name
  
  nRequestedColors = n_elements(colorname)
  
  if (keyword_set(index)) then begin
    result = nRequestedColors eq 1L ? 0L : lonarr(nRequestedColors)
  endif else begin
    result = bytarr(nRequestedColors, 3)
  endelse
  
  for i = 0L, nRequestedColors - 1L do begin
    ind = where(strlowcase(colorname[i]) eq colors.name, count)
    if (count eq 0L) then message, 'invalid color name'
    if (keyword_set(index)) then begin
      result[i] = colors[ind[0]].rgb
    endif else begin
      result[i, *] = vis_index2rgb(colors[ind[0]].rgb)
    endelse  
  endfor

  return, n_elements(result) gt 1L ? reform(result) : result
end


; main-level example program

print, vis_color('black')
print, vis_color('slateblue')
c = vis_color('slateblue', /index) 
print, c, c, format='(I, Z)'
print, vis_color(['blue', 'red', 'yellow'])
print, vis_color(/names)

end