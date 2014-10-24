; docformat = 'rst'

;+
; Converts color indices to RGB coordinates. Color indices are long integers
; used in decomposed color in direct graphics where the lowest order byte
; value is the red value, the next byte is the green value, the next byte is
; the blue value, and the highest order byte value is unused.
;
; :Categories:
;   direct graphics
;
; :Examples:
;   For example::
;
;     IDL> print, mg_index2rgb('ffff00'x)
;        0 255 255
;
;   Multiple colors can be converted at once::
;
;     IDL> colors = ['ffff00'x, 'ffffff'x, '0000ff'x, 'ff00ff'x]
;     IDL> rgbColors = mg_index2rgb(colors)
;     IDL> print, rgbColors
;        0 255 255 255
;      255 255   0   0
;      255 255   0 255
;     IDL> tvlct, rgbColors
;
; :Returns:
;   `bytarr(3)` or `bytarr(n, 3)`; string or `strarr(n)`
;
; :Params:
;   indices : in, required, type=long or lonarr(n)
;     indices representing either a color or n colors
;
; :Keywords:
;   hex : in, optional, type=boolean
;     set to return a string instead of a `bytarr(3)`; string formatted
;     according to HTML/CSS conventions: `#RRGGBB`
;-
function mg_index2rgb, indices, hex=hex
  compile_opt strictarr

  r = indices and 255B
  g = ishft(indices, -8) and 255B
  b = ishft(indices, -16) and 255B

  if (keyword_set(hex)) then begin
    return, string(transpose([[r], [g], [b]]), format='("#", 3Z02)')
  endif else begin
    return, byte(reform([[r], [g], [b]]))
  endelse
end


; main-level example program

print, mg_index2rgb('ffff00'x)
colors = ['ffff00'x, 'ffffff'x, '0000ff'x, 'ff00ff'x]
rgbColors = mg_index2rgb(colors)
print, rgbColors
tvlct, rgbColors

end
