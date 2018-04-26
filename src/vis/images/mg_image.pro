; docformat = 'rst'

;+
; Displays an image scaled to a "reasonable" size with x- and y-axes.
;
; :Todo:
;    adjustment for line thickness is not correct; add XLOG and YLOG keywords
;
; :Author:
;    Michael Galloy
;
; :Categories:
;    direct graphics
;
; :Examples:
;    For example, create an example image using `MG_LIC` and display with
;    appropriate axes scale labels::
;
;       scale = 4L
;       restore, filepath('globalwinds.dat', subdir=['examples','data'])
;
;       u = rebin(u, 128L * scale, 64L * scale)
;       v = rebin(v, 128L * scale, 64L * scale)
;       x = rebin(x, 128L * scale)
;       y = rebin(y, 64L * scale)
;
;      im = mg_lic(u, v)
;      mg_image, im, x, y, xticks=4, yticks=4, /interp, /axes, /new_window
;
;    This should produce output like:
;
;    .. image:: mg_image.png
;-


;+
; Helper routine to handle images that may have an alpha channel.
;
; :Private:
;
; :Params:
;    im : in, required, type=image
;       image to display
;    x : in, required, type=float
;       x location to display image
;    y : in, required, type=float
;       y location to display image
;
; :Keywords:
;    scale : in, optional, type=boolean
;       set to use TVSCL instead of TV
;    n_channels : in, required, type=int
;       number of channels present in the image
;    true : in, required, type=int
;       TRUE value for the image
;    min_value : in, optional, type="same as data"
;       miniumum value to display in the image, smaller values will be truncated
;       to the `MIN` value
;    max_value : in, optional, type="same as data"
;       maximum value to display in the image, larger values will be truncated
;       to the `MAX` value
;    _extra : in, optional, type=keywords
;       keywords to TV or TVSCL
;-
pro mg_image_tv, im, x, y, scale=scale, n_channels=nchannels, true=true, $
                 min_value=min_value, max_value=max_value, _extra=e
  compile_opt strictarr
  on_error, 2

  _true = true
  case nchannels of
    1: lastChannel = 0L
    2: begin
        lastChannel = 0L
        _true = 0L
      end
    3: lastChannel = 2L
    4: lastChannel = 2L
    else: message, 'invalid number of channels'
  endcase

  case true of
    0: _im = im
    1: _im = reform(im[0:lastChannel, *, *])
    2: _im = reform(im[*, 0:lastChannel, *])
    3: _im = reform(im[*, *, 0:lastChannel])
    else: message, 'invalid TRUE value'
  endcase

  if (keyword_set(scale)) then begin
    tv, bytscl(_im, min=min_value, max=max_value), x, y, true=_true, _extra=e
  endif else begin
    tv, _im, x, y, true=_true, _extra=e
  endelse
end


;+
; Make sure that !d is set correctly.
;
; :Private:
;-
pro mg_image_setdims
  compile_opt strictarr

  ; other devices besides a graphics window
  if (!d.name ne 'X' && !d.name ne 'WIN') then return

  ; existing graphics window
  if (!d.window ne -1L) then return

  window, /pixmap
  wdelete, !d.window
end


;+
; Displays an image scaled to a "reasonable" size with optional x- and y-axes.
;
; :Params:
;    im : in, required, type=image array
;       image array
;    x : in, optional, type=fltarr, default=bindgen(xsize)
;       x-axis values
;    y : in, optional, type=fltarr, default=bindgen(ysize)
;       y-axis values
;
; :Keywords:
;    true : in, optional, type=long
;       Set to 0 for (m, n) array images, 1 for (3, m, n),  2 for (m, 3, n),
;       and 3 for (m, n, 3).
;
;       If TRUE is not present, `MG_IMAGE_GETSIZE` will attempt to guess the
;       size. 2D images will automatically be set to TRUE=0; 3D images'
;       dimensions will be searched for a size 3 dimension.
;    stretch : in, optional, type=float
;       set to a value between `0.` and `100.` to stretch the histogram
;    min_value : in, optional, type="same as data"
;       miniumum value to display in the image, smaller values will be truncated
;       to the `MIN` value
;    max_value : in, optional, type="same as data"
;       maximum value to display in the image, larger values will be truncated
;       to the `MAX` value
;    axes : in, optional, type=boolean
;       set to display axes around the image
;    scale : in, optional, type=float, default=1.0
;       set to scale the creation of a new window to a fraction of the image
;       size
;    no_scale : in, optional, type=boolean
;       set to not scale the image values into the display range
;    no_data : in, optional, type=boolean
;       set to not diplay the image
;    new_window : in, optional, type=boolean
;       set to create a new window of the correct size as the image
;    position : in, optional, type=fltarr(4)
;       position of the image display, [xstart, ystart, xend, yend]
;    xmargin : in, optional, type=fltarr(2)
;       margin on left and right in character units
;    ymargin : in, optional, type=fltarr(2)
;       margin on bottom and top in character units
;    charsize : in, optional, type=float, default=1.0
;       multiplier for size of characters
;    ticklen : in, optional, type=float, default=-0.02
;       length of tickmarks in normalized window units
;    _extra : in, optional, type=keywords
;       keywords to PLOT, CONGRID, or WINDOW routines
;-
pro mg_image, im, x, y, $
              true=true, $
              stretch=stretch, $
              min_value=min_value, $
              max_value=max_value, $
              axes=axes, $
              scale=scale, $
              new_window=newWindow, $
              no_scale=noScale, $
              no_data=noData, $
              position=position, $
              xmargin=xmargin, ymargin=ymargin, $
              charsize=charsize, $
              ticklen=ticklen, $
              _extra=e
  compile_opt strictarr
  on_error, 2

  ndims = size(im, /n_dimensions)
  _ticklen = n_elements(ticklen) eq 0L ? -0.02 : ticklen

  if (n_elements(true) gt 0L) then _true = true
  dims = mg_image_getsize(im, true=_true, n_channels=nchannels)

  _scale = n_elements(scale) eq 0L ? 1.0 : scale
  dims *= _scale

  ; _position specifically not set in the case that POSITION not specified and
  ; AXES was not set
  if (n_elements(position) ne 0L) then begin
    _position = position
  endif else begin
    if (~keyword_set(axes)) then _position = [0., 0., 1., 1.]
  endelse

  if ((_true gt 0L && ndims ne 3) || (_true eq 0L && ndims ne 2L)) then begin
    message, 'TRUE keyword value does not match dimensionality of image'
  endif

  if (keyword_set(newWindow) && ((!d.name eq 'WIN' || !d.name eq 'X'))) then begin
    if (keyword_set(axes)) then begin
      if (n_elements(_position) gt 0L) then begin
        normalDims = [_position[2] - _position[0], _position[3] - _position[1]]
        wdims = dims / normalDims + 1
      endif else begin
        ; need to make sure !d is setup
        mg_image_setdims

        _xmargin = n_elements(xmargin) gt 0L ? xmargin : !x.margin
        _ymargin = n_elements(ymargin) gt 0L ? ymargin : !y.margin

        _charsize = [1.0, 1.0]
        if (n_elements(charsize) gt 0L) then _charsize *= charsize
        _charsize *= [!d.x_ch_size, !d.y_ch_size]

        wdims = dims + _charsize * [total(_xmargin), total(_ymargin)] + 1
      endelse
    endif else begin
      wdims = dims
    endelse

    window, /free, xsize=wdims[0], ysize=wdims[1], _extra=e
  endif

  ; if a window already exists fit the image into the window otherwise create
  ; one of a "good" size
  if (!d.name eq 'WIN' || !d.name eq 'X') then begin
    if (!d.window eq -1L) then begin
      if (~keyword_set(axes)) then begin
        wdims = dims
      endif else begin
        ss = get_screen_size()
        r = dims / ss
        if (r[0] gt 0.75 || r[1] gt 0.75) then begin
          rmax = max(r)
          wdims = 0.75 * dims / r
        endif else if (dims[0] lt 200 || dims[1] lt 200) then begin
          wdims =  0.25 * dims / min(r)
        endif else begin
          wdims = 1.1 * dims
        endelse
      endelse

      window, xsize=wdims[0], ysize=wdims[1], _extra=e
    endif
  endif

  _x = n_elements(x) eq 0L ? (findgen(dims[0] + 1L) / _scale) : x
  _y = n_elements(y) eq 0L ? (findgen(dims[1] + 1L) / _scale) : y

  if (~keyword_set(axes)) then begin
    plot, _x, _y, xstyle=5, ystyle=5, /nodata, position=_position, $
          xmargin=xmargin, ymargin=ymargin, _extra=e
  endif else begin
    plot, _x, _y, $
          /nodata, $
          xstyle=1, ystyle=1, $
          position=_position, xmargin=xmargin, ymargin=ymargin, $
          xrange=mg_range(_x), yrange=mg_range(_y), $
          charsize=charsize, $
          ticklen=_ticklen, $
          _extra=e
  endelse

  ; TODO: this thickness will not be correct in PS output
  lineThick = keyword_set(axes)

  lower = round(convert_coord(!x.window[0], !y.window[0], /normal, /to_device))
  upper = round(convert_coord(!x.window[1], !y.window[1], /normal, /to_device))
  displaySize = (upper - lower - lineThick) > 1

  ; cut down to min/max range
  _min_value = n_elements(min_value) eq 0L ? min(im) : min_value
  _max_value = n_elements(max_value) eq 0L ? max(im) : max_value

  _im = (im < _max_value) > _min_value

  ; stretch if requested
  _im = n_elements(stretch) eq 0L ? _im : hist_equal(_im, percent=stretch)

  if (~keyword_set(noData)) then begin
    ; use NO_SCALE value if explicitly set by caller, otherwise guess by data
    ; type (scale if not byte data)
    scale = n_elements(noScale) gt 0L $
              ? (1B - keyword_set(noScale)) $
              : (size(im, /type) ne 1L)
    if (!d.name eq 'PS') then begin
      mg_image_tv, _im, !x.window[0], !y.window[0], /normal, $
                   xsize=!x.window[1] - !x.window[0], $
                   ysize=!y.window[1] - !y.window[0], $
                   true=_true, scale=scale, n_channels=nchannels, _extra=e
    endif else begin
      displayIm = mg_image_resize(_im, displaySize[0], displaySize[1], $
                                  true=_true, _extra=e)
      mg_image_tv, displayIm, lower[0] + lineThick, lower[1] + lineThick, $
                   true=_true, scale=scale, n_channels=nchannels, $
                   min_value=_min_value, max_value=_max_value, _extra=e
    endelse
  endif

  ; overwrite in case image display has covered up axes
  if (~keyword_set(axes)) then begin
    plot, _x, _y, xstyle=5, ystyle=5, /nodata, /noerase, position=_position, $
          xmargin=xmargin, ymargin=ymargin, _extra=e
  endif else begin
    plot, _x, _y, $
          /nodata, /noerase, $
          xstyle=1, ystyle=1, $
          position=_position, xmargin=xmargin, ymargin=ymargin, $
          xrange=mg_range(_x), yrange=mg_range(_y), $
          charsize=charsize, $
          ticklen=_ticklen, $
          _extra=e
  endelse
end


; example main-level program
scale = 4L
restore, filepath('globalwinds.dat', subdir=['examples','data'])

u = rebin(u, 128L * scale, 64L * scale)
v = rebin(v, 128L * scale, 64L * scale)
x = rebin(x, 128L * scale)
y = rebin(y, 64L * scale)

im = mg_lic(u, v)
mg_image, im, x, y, xticks=4, yticks=4, /interp

end
