; docformat = 'rst'

;+
; Create a transparent box on a graphic. This can be used to create a 
; background over an image suitable for display text on.
;
; :Examples:
;    For example, the main-level program at the end of this file makes use of
;    this routine to make a box over an image suitable as a background for 
;    text. To run the example, do::
;
;       IDL> .run mg_textbackground
;
;    This should produce the following graphic:
; 
;    .. image:: mg_textbackground.png
;
;    The program displays an image, creates the text background, and then uses
;    `XYOUTS` to place text over the image::
;
;       IDL> mg_image, read_image(file_which('people.jpg')), /new_window
;       IDL> mg_textbackground, dimensions=[256, 40], alpha=0.75, /device
;       IDL> xyouts, 10, 23, 'Ali Bahrami!CRSI first employee', $
;       IDL>     /device, charsize=1.25, font=0
; 
; :Keywords:
;    color : in, optional, type=byte/long/bytarr(3), default=0
;       color over background
;    alpha : in, optional, type=float, default=0.5
;       alpha blending between background and `color`; value is 0.0 to 1.0 
;       where 0.0 is completely background and 1.0 is completely `color`
;    location : in, optional, type=lonarr(2)/fltarr(2)
;       lower-left location of box to draw; default depends on the coordinate 
;       system, uses `![xy].crange` in data coordinates, `[0, 0]` in device 
;       coordinates, `[0., 1]` in normal coordinates
;    dimensions : in, optional, type=lonarr(2)/fltarr(2)
;       width and height of box
;    data : in, optional, type=boolean
;       set to use data-coordinates (the default) for `LOCATION` and 
;       `DIMENSIONS`
;    device : in, optional, type=boolean
;       set to use device coordinates for `LOCATION` and `DIMENSIONS`
;    normal : in, optional, type=boolean
;       set to use normal coordinates for `LOCATION` and `DIMENSIONS`
;-
pro mg_textbackground, color=color, $
                       alpha=alpha, $
                       location=location, $
                       dimensions=dimensions, $
                       data=data, device=device, normal=normal
  compile_opt strictarr
  on_error, 2
  
  ; if there is not a current direct graphics window, you can't do this
  if (!d.window lt 0L) then message, 'no current graphics window'
  
  _color = n_elements(color) eq 0L ? 0L : color
  _data = ~keyword_set(device) && ~keyword_set(normal)
  _alpha = n_elements(alpha) eq 0L ? 0.5 : float(alpha)
  
  ; default location depends on coordinate system
  case 1 of
    n_elements(location) gt 0L: _location = location
    keyword_set(_data): _location = [!x.crange[0], !y.crange[0]]
    keyword_set(device): _location = lonarr(2)
    keyword_set(normal): _location = [0., 0.]
  endcase
  
  ; default dimensions depends on coordinate system
  case 1 of
    n_elements(dimensions) gt 0L: _dimensions = dimensions
    keyword_set(_data): begin
        _dimensions = [!x.crange[1] - !x.crange[0], $
                       !y.crange[1] - !y.crange[0]]
      end
    keyword_set(device): _dimensions = [!d.x_size, !d.y_size]
    keyword_set(normal): _dimensions = [1., 1.]
  endcase
  
  ; convert coordinates to device coordinates
  _location = convert_coord(_location, $
                            data=_data, device=device, normal=normal, $
                            /to_device)
  _dimensions = convert_coord(_dimensions, $
                              data=_data, device=device, normal=normal, $
                              /to_device)
                              
  ; read background
  im = tvrd(_location[0], _location[1], _dimensions[0], _dimensions[1], $
            true=1)

  device, get_decomposed=dec
  if (dec) then begin
    _color = n_elements(_color) gt 1L ? _color : mg_index2rgb(_color)
  endif else begin
    tvlct, r, g, b, /get
    _color = [r[_color], g[_color], b[_color]]
  endelse
  
  background = im * 0
  background[0, *, *] = _color[0]
  background[1, *, *] = _color[1]
  background[2, *, *] = _color[2]
  
  blend = mg_blend(background, im, alpha=_alpha)

  tv, blend, _location[0], _location[1], true=1
end


; main-level example program

mg_image, read_image(file_which('people.jpg')), /new_window
mg_textbackground, dimensions=[256, 40], alpha=0.75, /device
xyouts, 10, 23, 'Ali Bahrami!CRSI first employee', $
        /device, charsize=1.25, font=0

end
