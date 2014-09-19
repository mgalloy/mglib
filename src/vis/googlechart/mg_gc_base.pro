; docformat = 'rst'

;+
; Process a string for inclusion in the URL: replace spaces with + signs,
; join multiple array elements with |'s, and add the param=. If no string is
; specified, the empty string will be returned.
;
; :Returns:
;   string
;
; :Params:
;   s : in, optional, type=string
;     string to process
;   param : in, optional, type=string
;     parameter name
;-
function mg_gc_base_processstr, s, param
  compile_opt strictarr

  if (n_elements(s) ne 0L) then begin
    _bs = byte(strjoin(s, '|'))
    ind = where(_bs eq 32B, count)
    if (count gt 0L) then _bs[ind] = 43B   ; 43B = '+' in ASCII
    _s = '&' + param + '=' + string(_bs)
  endif else begin
    _s = ''
  endelse

  return, _s
end


;+
; Interface to Google Charts API. Returns an image to display. The Google
; Charts API is documented at::
;
;   http://code.google.com/apis/chart/
;
; :Requires:
;   IDL 6.4
;
; :Examples:
;   An example of using the routine is given in a main-level program at the
;   end of this file. Run it using::
;
;     IDL> .run mg_gc_base
;
;   It produces:
;
;   .. image:: gc_piechart.png
;
; :Returns:
;   `bytarr(3, xsize, ysize)`
;
; :Keywords:
;   type : in, required, type=string
;     type of chart required, options are: lc (line chart), lxy (xy points),
;     ls (sparkline), bhs, bvs, bhg, bvg, p (pie chart), p3 (3D pie chart),
;     v (Venn diagram), s (scatter plot), r (radar), t (map),
;     gom (Google-o-meter)
;   data : in, required, type=numeric
;     array of data to displayed
;   range : in, optional, type=fltarr
;     range of data
;   label : in, optional, type=strarr
;     chart labels (depending on type)
;   dimensions : in, optional, type=lonarr(2), default="[200, 100]"
;     size of returned image
;   color : in, optional, type=lonarr
;     colors of the chart
;   background : in, optional, type=long
;     color of background
;   alpha_channel : in, optional, type=float
;     transparency of chart: 0.0 for completely transparent, 1.0 for
;     completely opaque
;   title : in, optional, type=string or strarr
;     title of the chart
;   legend_labels : in, optional, type=strarr
;     string array of labels for sets
;   legend_position : in, optional, type=string
;     position of legend: t (top), b (bottom), r (right), or l (left)
;   axis_labels : in, optional, type=string
;     position of axis labels: t (top), b (bottom), r (right), or l (left)
;   bar_sizes : in, optional, type=numeric array
;     bar sizes
;   url : out, optional, type=string
;     URL used by Google Charts API
;   just_url : in, optional, type=boolean
;     set to just returned the URL via the `URL` keyword, not an image
;-
function mg_gc_base, type=type, $
                     data=data, $
                     range=range, $
                     dimensions=dimensions, $
                     title=title, $
                     label=label, $
                     legend_labels=legendLabels, $
                     legend_position=legendPosition, $
                     color=color, $
                     background=background, $
                     alpha_channel=alphaChannel, $
                     axis_labels=axisLabels, $
                     bar_sizes=barSizes, $
                     url=url, just_url=justUrl
  compile_opt strictarr

  ; construct the URL
  baseUrl = 'http://chart.apis.google.com/chart'

  _dims = n_elements(dimensions) eq 0L ? [200, 100] : dimensions
  _dims = 'chs=' + strjoin(strtrim(_dims, 2), 'x')

  _type = '&cht=' + type

  _data = '&chd=t:' + strjoin(strjoin(strtrim(data, 2), ','), '|')
  _range = n_elements(range) eq 0L $
             ? '' $
             : ('&chds=' + strjoin(strtrim(range, 2), ','))

  _label = n_elements(label) eq 0L ? '' : ('&chl=' + strjoin(label, '|'))
  _legendLabels = mg_gc_base_processstr(legendLabels, 'chdl')
  _legendPosition = n_elements(legendPosition) eq 0L $
                      ? '' $
                      : ('&chdlp=' + strjoin(legendPosition, '|'))
  _title = mg_gc_base_processstr(title, 'chtt')

  _barSizes = n_elements(barSizes) eq 0L $
                ? '' $
                : '&chbh=' + strjoin(strtrim(barSizes, 2), ',')

  device, get_decomposed=dec
  if (n_elements(color) ne 0L) then begin
    ; must turn around RGB triplets because result should be RRGGBB instead of
    ; BBGGRR
    if (dec eq 0L) then begin
      tvlct, r, g, b, /get
      _color = mg_rgb2index([[b[color]], [g[color]], [r[color]]])
    endif else begin
      rgb = mg_index2rgb(color)
      if (size(rgb, /n_dimensions) eq 1L) then rgb = reform(rgb, 1, 3)
      _color = mg_rgb2index([[reform(rgb[*, 2])], $
                             [reform(rgb[*, 1])], $
                             [reform(rgb[*, 0])]])
    endelse

    _color = '&chco=' + strjoin(strtrim(string(_color, format='(z06)'), 2), ',')
  endif else _color = ''

  if (n_elements(background) gt 0L) then begin
    if (dec eq 0L) then begin
      tvlct, r, g, b, /get
      _fill = mg_rgb2index([b[background], g[background], r[background]])
    endif else begin
      rgb = mg_index2rgb(background)
      _fill = mg_rgb2index(reverse(rgb))
    endelse
    _fill = strtrim(string(_fill, format='(z06)'), 2)
  endif else begin
    _fill = 'ffffff'
  endelse

  if (n_elements(alphaChannel) gt 0L) then begin
    _fill = '&chf=a,s,' + _fill + string(255 * alphaChannel, format='(z02)')
  endif else begin
    _fill = '&chf=bg,s,' + _fill
  endelse

  if (n_elements(axisLabels) gt 0L) then begin
    nlabels = strlen(axisLabels)
    _axisLabels = '&chxt=' + strjoin(string(transpose(byte(axisLabels))), ',')
  endif else _axisLabels = ''

  url = baseUrl + '?' + _dims + _type + _data + _range $
          + _axisLabels + _title + _label $
          + _legendLabels + _legendPosition $
          + _color + _fill + _barSizes

  if (keyword_set(justUrl)) then return, -1L

  ; get the data
  tmpFile = filepath('googlevis.png', /tmp)   ; TODO: should contain unique identifier
  ourl = obj_new('IDLnetURL')
  imBuffer = ourl->get(filename=tmpFile, url=url)
  obj_destroy, ourl

  ; read the file and then get rid of it
  im = read_png(tmpFile)
  file_delete, tmpFile

  ; return the image data
  return, im
end


; main-level example program

dims = [300, 125]

im = mg_gc_base(type='p3', $
                data=[70, 30], $
                dimensions=dims, $
                label=['A', 'B'], $
                url=url)

window, xsize=dims[0], ysize=dims[1], title=url
tv, im, true=1

end
