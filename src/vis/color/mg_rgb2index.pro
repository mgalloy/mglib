; docformat = 'rst'

;+
; Convert RGB coordinates of colors to the decomposed color indices of the 
; colors. Color indices are long integers used in decomposed color in direct 
; graphics where the lowest order byte value is the red value, the next byte 
; is the green value, the next byte is the blue value, and the highest order 
; byte value is unused.
;
; :Categories:
;    direct graphics
;
; :Examples:
;    For example::
;
;       IDL> print, mg_rgb2index([255, 255, 255]), format='(Z06)'   ; white
;       FFFFFF
;       IDL> print, mg_rgb2index([255, 255, 0]), format='(Z06)'     ; yellow
;       00FFFF
;       IDL> print, mg_rgb2index([0, 0, 255]), format='(Z06)'       ; blue
;       FF0000
;
;    Multiple RGB triplets can also be passed to `MG_RGB2INDEX` in an `n` by 
;    3 byte array::
;
;       IDL> mg_loadct, 5, /brewer
;       % LOADCT: Loading table PuBu (Sequential)
;       IDL> tvlct, rgb, /get
;       IDL> print, mg_rgb2index(rgb), format='(8Z)'
;
; :Returns:
;    long or lonarr(n)
;
; :Params:
;    rgb : in, required, type=bytarr
;       either `bytarr(3)` or `bytarr(n, 3)` array of RGB coordinates of 
;       colors
;-
function mg_rgb2index, rgb
  compile_opt strictarr
  on_error, 2
  
  if (n_elements(rgb) lt 3L) then message, 'not enough elements in RGB array'
  
  ndims = size(rgb, /n_dimensions)
  
  case ndims of
    1: return, rgb[0] + rgb[1] * 2L^8 + rgb[2] * 2L^16
    2: return, rgb[*, 0] + rgb[*, 1] * 2L^8 + rgb[*, 2] * 2L^16
    else: message, 'invalid number of dimensions for RGB array'
  endcase
end


; main-level example program

print, mg_rgb2index([255, 255, 255]), format='(Z06)'   ; white
print, mg_rgb2index([255, 255, 0]), format='(Z06)'     ; yellow
print, mg_rgb2index([0, 0, 255]), format='(Z06)'       ; blue

mg_loadct, 5, /brewer
tvlct, rgb, /get
print, mg_rgb2index(rgb), format='(8Z)'

end
