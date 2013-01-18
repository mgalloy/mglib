; docformat = 'rst'

;+
; Represents a polyline in 3-dimensions by a series of cones.
;
; :Categories:
;    object graphics
;
; :Examples:
;    To create some tubes to visualize streamlines of a vector field::
;
;       streamlines = obj_new('MGgrPOVRayTubes', data=verts, polylines=conn, $
;                             /open, radius=0.5 - 0.5 / (findgen(nverts) + 1.1), $
;                             color=[r[mag], g[mag], b[mag]])
;
;    See the example attached to the end of this file as a main-level program
;    (only available if you have the source code version of this routine)::
;
;       IDL> .run mggrpovraytubes__define
;
;    This should produce:
;
;    .. image:: tubes.png
;
; :Properties:
;    open
;       set to control whether the ends are open or closed
;    radius
;       radius of the cones; either a scalar or a fltarr(n) where there are n
;       points in the polyline; default value is 1.0
;-


;+
; Write POV-Ray description of the tubes.
;
; :Private:
;
; :Params:
;    lun : in, required, type=long
;       logical unit number of file to write to
;-
pro mggrpovraytubes::write, lun
  compile_opt strictarr

  self->getProperty, data=verts, polylines=polylines, color=color, $
                     alpha_channel=alphaChannel

  dims = size(verts, /dimensions)
  nverts = (n_elements(dims) eq 1) ? dims[0] : dims[1]
  _polylines = n_elements(polylines) le 1L ? [nverts, lindgen(nverts)] : polylines

  nradii = n_elements(*self.radius)

  if (obj_valid(self.finish) && self.finish->hasName()) then begin
    printf, lun, '#include "metals.inc"'
    printf, lun, '#include "finish.inc"'
    printf, lun, '#include "textures.inc"'
    printf, lun
  endif

  pos = 0L
  npolylines = n_elements(_polylines)
  while (pos lt npolylines) do begin
    ntubes = _polylines[pos] - 1L

    for t = pos + 1L, pos + ntubes - 1L do begin
      d = verts[*, _polylines[t]] - verts[*, _polylines[t + 1L]]
      if (total(abs(d / verts[*, _polylines[t]])) lt 1e-3) then continue

      printf, lun, 'cone {'
      printf, lun, '  <' +  strjoin(strtrim(verts[*, _polylines[t]], 2), ', ') + '>, ' $
                     + strtrim((*self.radius)[_polylines[t] mod nradii], 2)
      printf, lun, '  <' +  strjoin(strtrim(verts[*, _polylines[t + 1L]], 2), ', ') + '>, ' $
                     + strtrim((*self.radius)[_polylines[t + 1] mod nradii], 2)

      if (self.open) then printf, lun, '  open'
      if (self.noShadow) then printf, lun, '  no_shadow'

      printf, lun, '  texture { pigment { ' $
                     + self->_getRGB(color, alpha_channel=alphaChannel) $
                     + ' }}'

      self->_writeTransform, lun, self->getCTM()

      if (obj_valid(self.finish)) then begin
        printf, lun
        self.finish->write, lun
      endif

      printf, lun, '}'
      printf, lun
    endfor

    pos += ntubes + 2L
  endwhile
end


;+
; Get properties.
;-
pro mggrpovraytubes::getProperty, open=open, radius=radius, finish=finish, $
                                  no_shadow=noShadow, $
                                  _ref_extra=e
  compile_opt strictarr

  if (arg_present(open)) then open = self.open
  if (arg_present(radius)) then radius = *self.radius
  if (arg_present(finish)) then finish = self.finish
  if (arg_present(noShadow)) then noShadow = self.noShadow

  if (n_elements(e) gt 0L) then begin
    self->idlgrpolyline::getProperty, _extra=e
  endif
end


;+
; Set properties.
;-
pro mggrpovraytubes::setProperty, open=open, radius=radius, finish=finish, $
                                  no_shadow=noShadow, $
                                  _extra=e
  compile_opt strictarr

  if (n_elements(open) gt 0L) then self.open = open
  if (n_elements(radius) gt 0L) then *self.radius = radius
  if (n_elements(finish) gt 0L) then self.finish = finish
  if (n_elements(noShadow) gt 0L) then self.noShadow = noShadow

  if (n_elements(e) gt 0L) then begin
    self->idlgrpolyline::setProperty, _extra=e
  endif
end


;+
; Free resources.
;-
pro mggrpovraytubes::cleanup
  compile_opt strictarr

  self->idlgrpolyline::cleanup
  ptr_free, self.radius
end


;+
; Create a POV-Ray tube object.
;
; :Returns:
;    1 for success, 0 for failure
;-
function mggrpovraytubes::init, open=open, radius=radius, finish=finish, $
                                no_shadow=noShadow, $
                                _extra=e

  if (~self->idlgrpolyline::init(_extra=e)) then return, 0
  if (~self->MGgrPOVRayObject::init()) then return, 0

  if (n_elements(open) gt 0L) then self.open = open
  if (n_elements(finish) gt 0L) then self.finish = finish
  self.radius = ptr_new(n_elements(radius) gt 0L ? radius : 1.0)
  self.noShadow = keyword_set(noShadow)

  return, 1
end


;+
; Define instance variables.
;
; :Fields:
;    open
;       1 if open ended cylinders, 0 if closed
;    radius
;       radius of the cylinders
;-
pro mggrpovraytubes__define
  compile_opt strictarr

  define = { MGgrPOVRayTubes, $
             inherits IDLgrPolyline, inherits MGgrPOVRayObject, $
             open: 0B, $
             radius: ptr_new(), $
             finish: obj_new(), $
             noShadow: 0B $
           }
end


; main-level example program

; TODO: get this example working

restore, filepath('globalwinds.dat', subdir=['examples','data'])
f = transpose([[[u]], [[v]]], [2, 0, 1])
f = rebin(reform(f, 2, 128, 64, 1), 2, 128, 64, 10)
newF = fltarr(3, 128, 64, 10)
newF[0, 0, 0, 0] = f
f = temporary(newF)

view = obj_new('IDLgrView', color=[0, 0, 0])

lightmodel = obj_new('IDLgrModel')
view->add, lightmodel

light = obj_new('IDLgrLight', type=2, location=[0, 0, 4])
lightmodel->add, light

model = obj_new('IDLgrModel')
view->add, model

xc = mg_linear_function([0, 127], [-0.8, 0.8])
yc = mg_linear_function([0, 63], [-0.4, 0.4])
zc = mg_linear_function([0, 9], [-0.05, 0.05])

m = sqrt(f[0, *, *, *] ^ 2 + f[1, *, *, *] ^ 2 + f[2, *, *, *] ^ 2)
m = bytscl(reform(m))
mg_loadct, /brewer, 16
tvlct, r, g, b, /get

finish = obj_new('MGgrPOVRayFinish', finish_name='F_MetalB')

for x = 0, 127, 4 do begin
  for y = 0, 63, 4 do begin
    particle_trace, f, [x, y, 5], verts, conn, max_iterations=1200
    nverts = n_elements(verts) / 3

    if (nverts le 3L) then continue

    mag = m[x, y, 5]

    streamlines = obj_new('MGgrPOVRayTubes', data=verts, polylines=conn, $
                          /open, radius=0.5 - 0.5 / (findgen(nverts) + 1.1), $
                          color=[r[mag], g[mag], b[mag]], finish=finish)
    model->add, streamlines

    streamlines->setProperty, xcoord_conv=xc, ycoord_conv=yc, zcoord_conv=zc
  endfor
endfor

model->rotate, [1, 0, 0], -90
model->rotate, [0, 1, 0], -30
model->rotate, [1, 0, 0], 30

dims = [800, 800]

win = obj_new('IDLgrWindow', dimensions=dims, graphics_tree=view)
win->draw

pov = obj_new('MGgrPOVRay', file_prefix='tubes-output/tubes', dimensions=dims)
file_mkdir, 'tubes-output'
pov->draw, view

obj_destroy, pov

; create an image of the scene with:
;
;    $ povray +P +A tubes.ini

window, xsize=dims[0], ysize=dims[1], title='POV-Ray tubes'
tubesImage = mg_povray('tubes-output/tubes')
tv, tubesImage, true=1

end
