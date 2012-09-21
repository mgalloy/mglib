;+
; Test binary VTK file office.binary.vtk.
;
; @returns 1 for success, 0 for failure
;-
function mgffserialvtk_ut::test_office
  compile_opt strictarr

  oVtk = obj_new('MGffSerialVTK', self.vtkDataPath + 'office.binary.vtk')

  o = oVtk->read()

  if self.view then begin
    o->setProperty, color=[200, 150, 50]
    xobjview, o, /block
  endif

  isPolygon = obj_isa(o, 'IDLgrPolygon')

  obj_destroy, [o, oVtk]

  if ~isPolygon then message, 'Not an IDLgrPolygon'

  return, 1
end


;+
; Test binary VTK file track1.binary.vtk.
;
; @returns 1 for success, 0 for failure
;-
function mgffserialvtk_ut::test_track1
  compile_opt strictarr

  oVtk = obj_new('MGffSerialVTK', self.vtkDataPath + 'track1.binary.vtk')

  o = oVtk->read()

  if self.view then begin
    o->setProperty, color=[200, 150, 50]
    xobjview, o, /block
  endif

  isPolygon = obj_isa(o, 'IDLgrPolygon')

  obj_destroy, [o, oVtk]

  if ~isPolygon then message, 'Not an IDLgrPolygon'

  return, 1
end


;+
; Test binary VTK file track2.binary.vtk.
;
; @returns 1 for success, 0 for failure
;-
function mgffserialvtk_ut::test_track2
  compile_opt strictarr

  oVtk = obj_new('MGffSerialVTK', self.vtkDataPath + 'track2.binary.vtk')

  o = oVtk->read()

  if self.view then begin
    o->setProperty, color=[200, 150, 50]
    xobjview, o, /block
  endif

  isPolygon = obj_isa(o, 'IDLgrPolygon')

  obj_destroy, [o, oVtk]

  if ~isPolygon then message, 'Not an IDLgrPolygon'

  return, 1
end

;+
; Test binary VTK file track3.binary.vtk.
;
; @returns 1 for success, 0 for failure
;-
function mgffserialvtk_ut::test_track2
  compile_opt strictarr

  oVtk = obj_new('MGffSerialVTK', self.vtkDataPath + 'track3.binary.vtk')

  o = oVtk->read()

  if self.view then begin
    o->setProperty, color=[200, 150, 50]
    xobjview, o, /block
  endif

  isPolygon = obj_isa(o, 'IDLgrPolygon')

  obj_destroy, [o, oVtk]

  if ~isPolygon then message, 'Not an IDLgrPolygon'

  return, 1
end


;+
; Test binary VTK file ironProt.vtk.
;
; @returns 1 for success, 0 for failure
;-
function mgffserialvtk_ut::test_ironProt
  compile_opt strictarr

  oVtk = obj_new('MGffSerialVTK', self.vtkDataPath + 'ironProt.vtk')

  o = oVtk->read()

  if self.view then begin
    o->setProperty, color=[200, 150, 50]
    xobjview, o, /block
  endif

  isPolygon = obj_isa(o, 'IDLgrPolygon')

  obj_destroy, [o, oVtk]

  if ~isPolygon then message, 'Not an IDLgrPolygon'

  return, 1
end


;+
; Test binary VTK file faults.vtk.
;
; @returns 1 for success, 0 for failure
;-
function mgffserialvtk_ut::test_faults
  compile_opt strictarr

  oVtk = obj_new('MGffSerialVTK', self.vtkDataPath + 'faults.vtk', $
                 /swap_if_little_endian)

  o = oVtk->read()

  if self.view then begin
    o->setProperty, color=[200, 150, 50]
    xobjview, o, /block
  endif

  isPolyline = obj_isa(o, 'IDLgrPolyline')

  obj_destroy, [o, oVtk]

  if ~isPolyline then message, 'Not an IDLgrPolyline'

  return, 1
end


;+
; Test uGridEx.vtk.
;
; @returns 1 for success, 0 for failure
;-
function mgffserialvtk_ut::test_uGridEx
  compile_opt strictarr

  oVtk = obj_new('MGffSerialVTK', self.vtkDataPath + 'uGridEx.vtk')

  o = oVtk->read()

  if self.view then begin
    o->setProperty, color=[200, 150, 50]
    xobjview, o, /block
  endif

  isPolygon = obj_isa(o, 'IDLgrPolygon')

  obj_destroy, [o, oVtk]

  if ~isPolygon then message, 'Not an IDLgrPolygon'

  return, 1
end


;+
; Test texThres2.vtk.
;
; @returns 1 for success, 0 for failure
;-
function mgffserialvtk_ut::test_texThres2
  compile_opt strictarr

  oVtk = obj_new('MGffSerialVTK', self.vtkDataPath + 'texThres2.vtk')

  o = oVtk->read()

  if self.view then begin
    o->setProperty, color=[200, 150, 50]
    xobjview, o, /block
  endif

  isPolygon = obj_isa(o, 'IDLgrPolygon')

  obj_destroy, [o, oVtk]

  if ~isPolygon then message, 'Not an IDLgrPolygon'

  return, 1
end


;+
; Test tetraMesh.vtk.
;
; @returns 1 for success, 0 for failure
;-
function mgffserialvtk_ut::test_tetraMesh
  compile_opt strictarr

  oVtk = obj_new('MGffSerialVTK', self.vtkDataPath + 'tetraMesh.vtk')

  o = oVtk->read()

  if self.view then begin
    o->setProperty, color=[200, 150, 50]
    xobjview, o, /block
  endif

  isPolygon = obj_isa(o, 'IDLgrPolygon')

  obj_destroy, [o, oVtk]

  if ~isPolygon then message, 'Not an IDLgrPolygon'

  return, 1
end


;+
; Test matrix.vtk.
;
; @returns 1 for success, 0 for failure
;-
function mgffserialvtk_ut::test_matrix
  compile_opt strictarr

  oVtk = obj_new('MGffSerialVTK', self.vtkDataPath + 'matrix.vtk')

  o = oVtk->read()

  if self.view then begin
    o->setProperty, color=[200, 150, 50]
    xobjview, o, /block
  endif

  isPolygon = obj_isa(o, 'IDLgrPolygon')

  obj_destroy, [o, oVtk]

  if ~isPolygon then message, 'Not an IDLgrPolygon'

  return, 1
end


;+
; Test qualityEx.vtk.
;
; @returns 1 for success, 0 for failure
;-
function mgffserialvtk_ut::test_qualityEx
  compile_opt strictarr

  oVtk = obj_new('MGffSerialVTK', self.vtkDataPath + 'qualityEx.vtk')

  o = oVtk->read()

  if self.view then begin
    o->setProperty, color=[200, 150, 50]
    xobjview, o, /block
  endif

  isPolygon = obj_isa(o, 'IDLgrPolygon')

  obj_destroy, [o, oVtk]

  if ~isPolygon then message, 'Not an IDLgrPolygon'

  return, 1
end

;+
; Test tensors.vtk.
;
; @returns 1 for success, 0 for failure
;-
function mgffserialvtk_ut::test_tensors
  compile_opt strictarr

  oVtk = obj_new('MGffSerialVTK', self.vtkDataPath + 'tensors.vtk')

  o = oVtk->read()

  if self.view then begin
    o->setProperty, color=[200, 150, 50]
    xobjview, o, /block
  endif

  isPolygon = obj_isa(o, 'IDLgrPolygon')

  obj_destroy, [o, oVtk]

  if ~isPolygon then message, 'Not an IDLgrPolygon'

  return, 1
end


;+
; Test fieldfile.vtk.
;
; @returns 1 for success, 0 for failure
;-
function mgffserialvtk_ut::test_fieldFile
  compile_opt strictarr

  oVtk = obj_new('MGffSerialVTK', self.vtkDataPath + 'fieldfile.vtk')

  o = oVtk->read()

  if self.view then begin
    o->setProperty, color=[200, 150, 50]
    xobjview, o, /block
  endif

  isPolygon = obj_isa(o, 'IDLgrPolygon')

  obj_destroy, [o, oVtk]

  if ~isPolygon then message, 'Not an IDLgrPolygon'

  return, 1
end


;+
; Test financial.vtk.
;
; @returns 1 for success, 0 for failure
;-
function mgffserialvtk_ut::test_financial
  compile_opt strictarr

  oVtk = obj_new('MGffSerialVTK', self.vtkDataPath + 'financial.vtk')

  o = oVtk->read()

  if self.view then begin
    o->setProperty, color=[200, 150, 50]
    xobjview, o, /block
  endif

  isPolygon = obj_isa(o, 'IDLgrPolygon')

  obj_destroy, [o, oVtk]

  if ~isPolygon then message, 'Not an IDLgrPolygon'

  return, 1
end


;+
; Test blowAttr.vtk.
;
; @returns 1 for success, 0 for failure
;-
function mgffserialvtk_ut::test_blowAttr
  compile_opt strictarr

  oVtk = obj_new('MGffSerialVTK', self.vtkDataPath + 'blowAttr.vtk')

  o = oVtk->read()

  if self.view then begin
    o->setProperty, color=[200, 150, 50]
    xobjview, o, /block
  endif

  isPolygon = obj_isa(o, 'IDLgrPolygon')

  obj_destroy, [o, oVtk]

  if ~isPolygon then message, 'Not an IDLgrPolygon'

  return, 1
end


;+
; Test blow.vtk.
;
; @returns 1 for success, 0 for failure
;-
function mgffserialvtk_ut::test_blow
  compile_opt strictarr

  oVtk = obj_new('MGffSerialVTK', self.vtkDataPath + 'blow.vtk')

  o = oVtk->read()

  if self.view then begin
    o->setProperty, color=[200, 150, 50]
    xobjview, o, /block
  endif

  isPolygon = obj_isa(o, 'IDLgrPolygon')

  obj_destroy, [o, oVtk]
 
 if ~isPolygon then message, 'Not an IDLgrPolygon'

  return, 1
end


;+
; Test blowGeom.vtk.
;
; @returns 1 for success, 0 for failure
;-
function mgffserialvtk_ut::test_blowGeom
  compile_opt strictarr

  oVtk = obj_new('MGffSerialVTK', self.vtkDataPath + 'blowGeom.vtk')

  o = oVtk->read()

  if self.view then begin
    o->setProperty, color=[200, 150, 50]
    xobjview, o, /block
  endif

  isPolygon = obj_isa(o, 'IDLgrPolygon')

  obj_destroy, [o, oVtk]

  if ~isPolygon then message, 'Not an IDLgrPolygon'

  return, 1
end


;+
; Test RectGrid2.vtk.
;
; @returns 1 for success, 0 for failure
;-
function mgffserialvtk_ut::test_rectGrid2
  compile_opt strictarr

  oVtk = obj_new('MGffSerialVTK', self.vtkDataPath + 'RectGrid2.vtk')

  o = oVtk->read()

  if self.view then begin
    o->setProperty, color=[200, 150, 50]
    xobjview, o, /block
  endif

  isPolygon = obj_isa(o, 'IDLgrPolygon')

  obj_destroy, [o, oVtk]

  if ~isPolygon then message, 'Not an IDLgrPolygon'

  return, 1
end


;+
; Test PentaHexa.vtk.
;
; @returns 1 for success, 0 for failure
;-
function mgffserialvtk_ut::test_pentaHexa
  compile_opt strictarr

  oVtk = obj_new('MGffSerialVTK', self.vtkDataPath + 'PentaHexa.vtk')

  o = oVtk->read()

  if self.view then begin
    o->setProperty, color=[200, 150, 50]
    xobjview, o, /block
  endif

  isPolygon = obj_isa(o, 'IDLgrPolygon')

  obj_destroy, [o, oVtk]

  if ~isPolygon then message, 'Not an IDLgrPolygon'

  return, 1
end


;+
; Test brainImageSmooth.vtk; a set of polygons in the shape of a brain.
;
; @returns 1 for success, 0 for failure
;-
function mgffserialvtk_ut::test_brainImageSmooth
  compile_opt strictarr

  oVtk = obj_new('MGffSerialVTK', self.vtkDataPath + 'brainImageSmooth.vtk')

  o = oVtk->read()

  isPolygon = obj_isa(o, 'IDLgrPolygon')
  o->getProperty, normals=normals, data=data, polygons=polygons
  hasNormals = n_elements(normals) gt 1
  hasCorrectSize = array_equal(size(data, /dimensions), [3, 5153])
  hasCorrectNPolygons = n_elements(polygons) eq 4L * 9522L

  if self.view then begin
    o->setProperty, color=[200, 150, 50]
    xobjview, o, /block
  endif

  obj_destroy, [o, oVtk]

  if ~isPolygon then message, 'Not an IDLgrPolygon'
  if ~hasNormals then message, 'Doesn''t have precomputed normals'
  if ~hasCorrectSize then message, 'Doesn''t have correct number of points'
  if ~hasCorrectNPolygons then begin
    message, 'Doesn''t have the correct number of polygons'
  endif

  return, 1
end


;+
; Test fran_cut.vtk; a set of polygons showing a human face.
;
; @returns 1 for success, 0 for failure
;-
function mgffserialvtk_ut::test_francut
  compile_opt strictarr

  oVtk = obj_new('MGffSerialVTK', self.vtkDataPath + 'fran_cut.vtk')

  o = oVtk->read()

  if self.view then begin
    face = read_png(self.vtkDataPath + 'fran_cut.png')
    oImage = obj_new('IDLgrImage', face)
    o->setProperty, texture_map=oImage
    xobjview, o, /block
  endif

  isPolygon = obj_isa(o, 'IDLgrPolygon')

  obj_destroy, [o, oVtk]
  if obj_valid(oImage) then obj_destroy, oImage

  if ~isPolygon then message, 'Not an IDLgrPolygon'

  return, 1
end


;+
; Test plate.vtk.
;
; @returns 1 for success, 0 for failure
;-
function mgffserialvtk_ut::test_plate
  compile_opt strictarr

  oVtk = obj_new('MGffSerialVTK', self.vtkDataPath + 'plate.vtk')

  o = oVtk->read()

  if self.view then xobjview, o, /block

  isPolygon = obj_isa(o, 'IDLgrPolygon')

  obj_destroy, [o, oVtk]

  if ~isPolygon then message, 'Not an IDLgrPolygon'
  message, 'Doesn''t do anything with VECTORS in POINT_DATA'

  return, 1
end


;+
; Test polyEx.vtk.
;
; @returns 1 for success, 0 for failure
;-
function mgffserialvtk_ut::test_polyex
  compile_opt strictarr

  oVtk = obj_new('MGffSerialVTK', self.vtkDataPath + 'polyEx.vtk')

  o = oVtk->read()

  if self.view then xobjview, o, /block

  isPolygon = obj_isa(o, 'IDLgrPolygon')

  obj_destroy, [o, oVtk]

  if ~isPolygon then message, 'Not an IDLgrPolygon'
  message, 'Doesn''t read CELL_DATA or POINT_DATA yet.'
  
  return, 1
end


;+
; Test bore.vtk.
;
; @returns 1 for success, 0 for failure
;-
function mgffserialvtk_ut::test_bore
  compile_opt strictarr

  oVtk = obj_new('MGffSerialVTK', self.vtkDataPath + 'bore.vtk')

  o = oVtk->read()

  if self.view then xobjview, o, /block

  isPolyline = obj_isa(o, 'IDLgrPolyline')

  obj_destroy, [o, oVtk]

  if ~isPolyline then message, 'Not an IDLgrPolyline'

  return, 1
end


;+
; Test vtk.vtk; a set of polylines spelling out "vtk."
;
; @returns 1 for success, 0 for failure
;-
function mgffserialvtk_ut::test_vtk
  compile_opt strictarr

  oVtk = obj_new('MGffSerialVTK', self.vtkDataPath + 'vtk.vtk')

  o = oVtk->read()

  if self.view then xobjview, o, /block

  isPolyline = obj_isa(o, 'IDLgrPolyline')

  obj_destroy, [o, ovtk]

  if ~isPolyline then message, 'Not an IDLgrPolyline'

  return, 1
end


;+
; Test usa.vtk; one polygon for each state in the United States.
;
; @returns 1 for success, 0 for failure
;-
function mgffserialvtk_ut::test_usa
  compile_opt strictarr

  oVtk = obj_new('MGffSerialVTK', self.vtkDataPath + 'usa.vtk')

  o = oVtk->read()

  if self.view then xobjview, o, /block

  isPolygon = obj_isa(o, 'IDLgrPolygon')

  obj_destroy, [o, oVtk]

  if ~isPolygon then message, 'Not an IDLgrPolygon'

  return, 1
end


;+
; Test hello.vtk; a set of polylines that spells out "Hello."
;
; @returns 1 for success, 0 for failure
;-
function mgffserialvtk_ut::test_hello
  compile_opt strictarr

  oVtk = obj_new('MGffSerialVTK', self.vtkDataPath + 'hello.vtk')

  o = oVtk->read()

  if self.view then xobjview, o, /block

  isPolyline = obj_isa(o, 'IDLgrPolyline')

  obj_destroy, [o, oVtk]

  if ~isPolyline then message, 'Not an IDLgrPolyline'

  return, 1
end


;+
; Initialize the test.
; 
; @returns 1 for success, 0 for failure
; @keyword _extra {in}{optional}{type=keywords}
;          keywords to MGutTestCase::init
;-
function mgffserialvtk_ut::init, _extra=e
  compile_opt strictarr

  if (~self->mguttestcase::init(_extra=e)) then return, 0

  traceback = scope_traceback(/structure)
  nLevels = n_elements(traceback)
  self.vtkDataPath = file_dirname(traceback[nLevels - 1L].filename, $
                                  /mark_directory)
  self.vtkDataPath += 'vtkdata' + path_sep()
  ;self.vtkDataPath = '/Users/mgalloy/projects/VTKData/Data/'
  self.view = 0B

  return, 1
end


;+
; Define member variables.
;
; @field vtkDataPath file path ending in / to the VTK data files
; @field view boolean on whether to view the results in XOBJVIEW or just do the 
;        analytic testing
;-
pro mgffserialvtk_ut__define
  compile_opt strictarr

  define = { mgffserialvtk_ut, inherits MGutTestCase, $
             vtkDataPath : '', $
             view : 0B $
           }
end
