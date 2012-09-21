; docformat = 'rst'

;+
; Scatter plot using Google Charts API.
;
; :Requires:
;    IDL 6.4
;
; :Examples:
;    Run the main-level example program::
;
;       IDL> .run vis_gc_scatter
;
;    It should generate:
; 
;    .. image:: gc_scatter.png
;
; :Returns:
;    bytarr(3, xsize, ysize)
;
; :Params:
;    x : in, required, type=fltarr
;       x-coordinate data
;    y : in, required, type=fltarr
;       y-coordinate data
;
; :Keywords:
;    xrange : in, optional, type=fltarr(2)
;       x-coordinate range of data
;    yrange : in, optional, type=fltarr(2)
;       y-coordinate range of data
;    sym_size : in, optional, type=fltarr(n)
;       size of each point in the scatter plot
;    dimensions : in, optional, type=lonarr, default="[200, 100]"
;       size of output image
;    url : out, optional, type=string
;       URL used by Google Charts API
;-
function vis_gc_scatter, x, y, $
                         xrange=xrange, yrange=yrange, $
                         sym_size=symSize, $
                         dimensions=dimensions, $
                         url=url
  compile_opt strictarr
  
  _xrange = n_elements(xrange) eq 0L ? [min(x, max=xmax), xmax] : xrange
  _yrange = n_elements(yrange) eq 0L ? [min(y, max=ymax), ymax] : yrange
  range = [_xrange, _yrange]
  
  data = [[x], [y]]
  if (n_elements(symSize) gt 0L) then begin
    data = [[data], [fltarr(n_elements(x)) + symSize]]
  endif
  
  return, vis_gc_base(data=data, $
                      range=range, $
                      type='s', $
                      dimensions=dimensions, $
                      title=title, label=label, $
                      color=color, $
                      axis_labels='xy', $
                      url=url)
end


; main-level example program

n = 20
x = randomu(seed, n)
y = randomu(seed, n)
s = randomu(seed, n)

im = vis_gc_scatter(x, y, sym_size=s, dimensions=[400, 400], url=url)
window, xsize=400, ysize=400, title=url
tv, im, true=1

end
