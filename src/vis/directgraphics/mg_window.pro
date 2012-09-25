; docformat = 'rst'

;+
; Creates a "window" of the given size on the current device.
;
; :Todo:
;    need to handle XPOS/YPOS/LOCATION for PS device
; 
; :Params:
;    index : in, optional, type=long
;
; :Keywords:
;    xsize : in, optional, type=long
;       xsize of the window in centimeters
;    ysize : in, optional, type=long
;       ysize of the window in centimeters
;    dimensions : in, optional, type=lonarr(2)
;       alternative to XSIZE and YSIZE
;    xpos : in, optional, type=long
;       offset of the window in the horizontal direction from the lower left 
;       corner
;    ypos : in, optional, type=long
;       offset of the window in the vertical direction from the lower left
;       corner
;    location : in, optional, type=lonarr(2)
;       alternative to XPOS and YPOS 
;    inches : in, optional, type=boolean
;       set to specify the XSIZE, YSIZE, XPOS, and YPOS in inches
;    pixels : in, optional, type=boolean
;       set to specify the XSIZE, YSIZE, XPOS, and YPOS in pixels
;    identifier : out, optional, type=long
;       set to a named variable to get the window identifier if the current
;       device is WIN or X
;    _extra : in, optional, type=keywords
;       keywords to the WINDOW routine
;-
pro mg_window, index, $
               xsize=xsize, ysize=ysize, dimensions=dimensions, $
               xpos=xpos, ypos=ypos, location=location, $
               inches=inches, pixels=pixels, $
               identifier=identifier, $
               _extra=e
  compile_opt strictarr
  on_error, 2
  
  ; nothing required if NULL device
  if (!d.name eq 'NULL') then return
  
  _inches = keyword_set(inches)
  _pixels = keyword_set(pixels)
  
  if (n_elements(dimensions) eq 0L) then begin
    case !d.name of
      'X': _dimensions = [pref_get('IDL_GR_X_WIDTH'), pref_get('IDL_GR_X_HEIGHT')]
      'WIN': _dimensions = [pref_get('IDL_GR_WIN_WIDTH'), pref_get('IDL_GR_WIN_HEIGHT')]
      'PS': _dimensions = [640, 480]   ; TODO: what is the real value?
      'Z': _dimensions = [640, 480]
      else: message, 'devices besides X, WIN, Z, PS, and NULL are currently not supported'
    endcase
    
    if (~_pixels) then _dimensions /= !d.y_px_cm * (_inches ? 2.54 : 1.)
  endif else begin
    _dimensions = dimensions
  endelse
  
  if (n_elements(xsize) gt 0L) then _dimensions[0] = xsize
  if (n_elements(ysize) gt 0L) then _dimensions[1] = ysize
   
  if (n_elements(xpos) gt 0L || n_elements(ypos) gt 0L || n_elements(location) gt 0L) then begin
    _xpos = n_elements(location) gt 0L ? location[0] : 0L
    if (n_elements(xpos) gt 0L) then _xpos = xpos

    _ypos = n_elements(location) gt 0L ? location[1] : 0L
    if (n_elements(ypos) gt 0L) then _ypos = ypos
  endif
  
  switch !d.name of
    'X':
    'WIN': begin
        if (~_pixels) then _dimensions *= !d.y_px_cm * (_inches ? 2.54 : 1.)
        if (~_pixels && n_elements(_xpos) gt 0L) then begin
          _xpos *= !d.x_px_cm * (_inches ? 2.54 : 1.)
          _ypos *= !d.y_px_cm * (_inches ? 2.54 : 1.)          
        endif
        
        if (n_elements(_xpos) gt 0L && !d.name eq 'WIN') then begin
          ; TODO: may need to use IDLsysMonitorInfo for this on multi-monitor
          ; systems to get info for the correct monitor
          ss = get_screen_size()
          
          ; TODO: need to find a good value for titlebarHeight
          titlebarHeight = 15
          _ypos = ss[1] - _ypos - _dimensions[1] - titlebarHeight
        endif
        
        case n_params() of
          0: window, xsize=_dimensions[0], ysize=_dimensions[1], xpos=_xpos, ypos=_ypos, _extra=e
          1: window, index, xsize=_dimensions[0], ysize=_dimensions[1], xpos=_xpos, ypos=_ypos, _extra=e
        endcase
        
        if (arg_present(identifier)) then identifier = !d.window
        
        break
      end
    
    'PS': begin      
        ; TODO: handle _xpos and _ypos
        device, xsize=_dimensions[0], ysize=_dimensions[1], inches=_inches, $
                xoffset=_xpos, yoffset=_ypos
        
        break
      end
      
    'Z': begin
        if (~_pixels) then _dimensions *= !d.y_px_cm * (inches ? 2.54 : 1.)
              
        device, set_resolution=_dimensions
        
        break
      end
    else: message, 'devices besides X, WIN, Z, PS, and NULL are currently not supported'
  endswitch
end


; main-level example program

filename = filepath('elevbin.dat', subdir=['examples', 'data'])
data = bytarr(64, 64)
openr, lun, filename, /get_lun
readu, lun, data
free_lun, lun

device, decomposed=0

if (keyword_set(ps)) then mg_psbegin, filename='window.ps', /image

mg_window, xsize=4, ysize=4, /inches, title='MG_CONTOUR example'

mg_loadct, 0
mg_contour, data, nlevels=15, xstyle=1, ystyle=1, $
            position=[0.15, 0.15, 0.9, 0.9], $
            title='mg_contour example'

mg_loadct, 5, /brewer
mg_contour, data, /fill, nlevels=15, /overplot

mg_loadct, 0
mg_contour, data, /overplot, nlevels=15, /follow, /downhill

if (keyword_set(ps)) then begin
  mg_psend
  mg_convert, 'window', max_dimensions=[406, 406], output=im
  mg_image, im, /new_window
endif

end
