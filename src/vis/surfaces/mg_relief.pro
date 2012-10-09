; docformat = 'rst'


;+
; Create simple relief visualization for an elevation data set.
;
; :Examples:
;    Try the main-level example program at the end of this file::
;
;       IDL> .run mg_relief
;
;    This should produce::
;
;    .. image:: mg_relief.png
;
; :Returns:
;    `bytarr(3, xsize, ysize)`
;
; :Params:
;    elevation : in, required, type="fltarr(m, n)"
;       elevations to make relief for
;
; :Keywords:
;    dimensions : in, optional, type=lonarr(2), default="[m, n]"
;       dimensions of output image, defaults to size of input elevation array
;    color_table : in, optional, type=long
;       color table number
;    _extra : in, optional, type=keywords
;       keywords to `VISgrPalette::loadct`
;-
function mg_relief, elevation, dimensions=dims, color_table=color_table, $
                    _extra=e
  compile_opt strictarr

  _dims = n_elements(dims) eq 0 ? size(elevation, /dimensions) : dims
  _color_table = n_elements(color_table) eq 0L ? 39 : color_table

  view = obj_new('IDLgrView', $
                 color=[0B, 0B, 0B])

  model = obj_new('IDLgrModel')
  view->add, model

  palette = obj_new('VISgrPalette')
  palette->loadct, _color_table, _extra=e
  texture = obj_new('IDLgrImage', bytscl(elevation), palette=palette)

  s = obj_new('IDLgrSurface', elevation, style=2, /shading, $
              color=[255B, 255B, 255B], texture_map=texture)
  model->add, s

  s->getProperty, xrange=xr, yrange=yr, zrange=zr
  s->setProperty, xcoord_conv=mg_linear_function(xr, [-1., 1.]), $
                  ycoord_conv=mg_linear_function(yr, [-1., 1.]), $
                  zcoord_conv=mg_linear_function(zr, [-1., 1.])

  sun_light = obj_new('IDLgrLight', type=2, intensity=0.5, $
                      location=[-1., 1., 1])
  model->add, sun_light

  ambient_light = obj_new('IDLgrLight', type=0, intensity=0.9)
  model->add, ambient_light

  buffer = obj_new('IDLgrBuffer', dimensions=_dims, color_model=0)
  buffer->draw, view
  buffer->getProperty, image_data=im

  obj_destroy, [buffer, view, texture, palette]

  return, im
end


; main-level example program

restore, filename=file_which('marbells.dat')
dims = size(elev, /dimensions)
window, xsize=dims[0], ysize=dims[1], /free, title='Marbells relief'
tv, mg_relief(elev, color_table=26, /brewer, /reverse), true=1

end
