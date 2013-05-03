function mgffserialvtk_ut::_test_polygon, name, polygon=p, _extra=e
  compile_opt strictarr

  oVtk = obj_new('MGffSerialVTK', $
                 filepath(name, root=self.vtkDataPath), $
                 _extra=e)

  p = oVtk->read()

  if (self.view) then begin
    p->setProperty, color=[200, 150, 50]
    xobjview, p, /block
  endif

  isPolygon = obj_isa(p, 'IDLgrPolygon')

  obj_destroy, [p, oVtk]

  assert, isPolygon, 'not an IDLgrPolygon'

  return, 1

end


function mgffserialvtk_ut::_test_office
  compile_opt strictarr

  pass = self->_test_polygon('office.binary.vtk')
  return, pass
end


function mgffserialvtk_ut::_test_track1
  compile_opt strictarr

  pass = self->_test_polygon('track1.binary.vtk')
  return, pass
end


function mgffserialvtk_ut::_test_track2
  compile_opt strictarr

  pass = self->_test_polygon('track2.binary.vtk')
  return, pass
end


function mgffserialvtk_ut::_test_track3
  compile_opt strictarr

  pass = self->_test_polygon('track3.binary.vtk')
  return, pass
end


function mgffserialvtk_ut::_test_ironProt
  compile_opt strictarr

  pass = self->_test_polygon('ironProt.vtk')
  return, pass
end


function mgffserialvtk_ut::_test_faults
  compile_opt strictarr

  pass = self->_test_polygon('faults.vtk', /swap_if_little_endian)
  return, pass
end


function mgffserialvtk_ut::_test_uGridEx
  compile_opt strictarr

  pass = self->_test_polygon('uGridEx.vtk')
  return, pass
end


function mgffserialvtk_ut::_test_texThres2
  compile_opt strictarr

  pass = self->_test_polygon('texThres2.vtk')
  return, pass
end


function mgffserialvtk_ut::_test_tetraMesh
  compile_opt strictarr

  pass = self->_test_polygon('tetraMesh.vtk')
  return, pass
end


function mgffserialvtk_ut::_test_matrix
  compile_opt strictarr

  pass = self->_test_polygon('matrix.vtk')
  return, pass
end


function mgffserialvtk_ut::_test_qualityEx
  compile_opt strictarr

  pass = self->_test_polygon('qualityEx.vtk')
  return, pass
end


function mgffserialvtk_ut::_test_tensors
  compile_opt strictarr

  pass = self->_test_polygon('tensors.vtk')
  return, pass
end


function mgffserialvtk_ut::_test_fieldFile
  compile_opt strictarr

  pass = self->_test_polygon('fieldfile.vtk')
  return, pass
end


function mgffserialvtk_ut::_test_financial
  compile_opt strictarr

  pass = self->_test_polygon('financial.vtk')
  return, pass
end


function mgffserialvtk_ut::_test_blowAttr
  compile_opt strictarr

  pass = self->_test_polygon('blowAttr.vtk')
  return, pass
end


function mgffserialvtk_ut::_test_blow
  compile_opt strictarr

  pass = self->_test_polygon('blow.vtk')
  return, pass
end


function mgffserialvtk_ut::_test_blowGeom
  compile_opt strictarr

  pass = self->_test_polygon('blowGeom.vtk')
  return, pass
end


function mgffserialvtk_ut::_test_rectGrid2
  compile_opt strictarr

  pass = self->_test_polygon('RectGrid2.vtk')
  return, pass
end


function mgffserialvtk_ut::_test_pentaHexa
  compile_opt strictarr

  pass = self->_test_polygon('PentaHexa.vtk')
  return, pass
end


function mgffserialvtk_ut::_test_brainImageSmooth
  compile_opt strictarr

  pass = self->_test_polygon('brainImageSmooth.vtk', polygons=p)

  p->getProperty, normals=normals, data=data, polygons=polygons
  hasNormals = n_elements(normals) gt 1
  hasCorrectSize = array_equal(size(data, /dimensions), [3, 5153])
  hasCorrectNPolygons = n_elements(polygons) eq 4L * 9522L

  assert, isPolyline, 'not an IDLgrPolyline'
  assert, hasNormals, 'doesn''t have precomputed normals'
  assert, hasCorrectSize, 'doesn''t have correct number of points'
  assert, hasCorrectPolygons, 'doesn''t have the correct number of polygons'

  return, pass
end


function mgffserialvtk_ut::test_francut
  compile_opt strictarr

  oVtk = obj_new('MGffSerialVTK', filepath('fran_cut.vtk', root=self.vtkDataPath))

  o = oVtk->read()

  if (self.view) then begin
    face = read_png(self.vtkDataPath + 'fran_cut.png')
    oImage = obj_new('IDLgrImage', face)
    o->setProperty, texture_map=oImage
    xobjview, o, /block
  endif

  isPolygon = obj_isa(o, 'IDLgrPolygon')

  obj_destroy, [o, oVtk]
  if obj_valid(oImage) then obj_destroy, oImage

  assert, isPolygon, 'not an IDLgrPolygon'

  return, 1
end


function mgffserialvtk_ut::_test_plate
  compile_opt strictarr

  pass = self->_test_polygon('plate.vtk')
  assert, 0, 'doesn''t do anything with VECTORS in POINT_DATA'

  return, pass
end


function mgffserialvtk_ut::_test_polyex
  compile_opt strictarr

  pass = self->_test_polygon('polyEx.vtk')
  assert, 0, 'doesn''t read CELL_DATA or POINT_DATA yet.'

  return, pass
end


function mgffserialvtk_ut::_test_bore
  compile_opt strictarr

  pass = self->_test_polygon('bore.vtk')
  return, pass
end


function mgffserialvtk_ut::_test_vtk
  compile_opt strictarr

  pass = self->_test_polygon('vtk.vtk')
  return, pass
end


function mgffserialvtk_ut::test_usa
  compile_opt strictarr

  pass = self->_test_polygon('usa.vtk')
  return, pass
end


function mgffserialvtk_ut::_test_hello
  compile_opt strictarr

  pass = self->_test_polygon('hello.vtk')
  return, pass
end


function mgffserialvtk_ut::init, _extra=e
  compile_opt strictarr

  if (~self->mgutlibtestcase::init(_extra=e)) then return, 0
  self.vtkDataPath = filepath('', $
                              subdir=['vis_ut', 'vtk_ut', 'vtkdata'], $
                              root=self.root)

  self.view = 0B

  return, 1
end


pro mgffserialvtk_ut__define
  compile_opt strictarr

  define = { mgffserialvtk_ut, inherits MGutLibTestCase, $
             vtkDataPath : '', $
             view : 0B $
           }
end
