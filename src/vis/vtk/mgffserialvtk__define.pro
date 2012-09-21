;+
; Reads connectivity list section and returns the connectivity list.
; 
; :Returns:
;    `lonarr`
;
; :Params:
;    nItems : in, required, type=integer
;       the number of polygons
;    size : in, required, type=integer
;       total number of elements in the connectivity list
;-
function mgffserialvtk::readConnectivityListSection, nItems, size
  compile_opt strictarr

  conn = lonarr(size)
  self->getData, conn

  return, conn
end


;+
; Reads a `POINTS` section and returns the points.
;
; :Returns:
;    `(3, nPoints)` array of given type
;
; :Params:
;    nPoints : in, required, type=integer
;       number of points
;    type : in, required, type=integer
;       IDL type code for the data type of the points
;-
function mgffserialvtk::readPointsSection, nPoints, type
  compile_opt strictarr

  nDimensions = 3L
  points = make_array(nPoints * nDimensions, type=type)
  self->getData, points

  return, reform(points, nDimensions, nPoints)
end


;+
; Reads the sections of a POLYDATA dataset.
;
; :Returns: 
;    object
;-
pro mgffserialvtk::readPolydataDataset
  compile_opt strictarr, logical_predicate
  
  done = 0B

  while (~eof(self.lun) && ~done) do begin
    sectionLine = self->getLine()
    sectionTokens = strsplit(sectionLine, /extract)
    
    case strlowcase(sectionTokens[0]) of
      'points' : begin
        nPoints = long(sectionTokens[1])
        type = self->convertVtkTypeToIdlType(sectionTokens[2])
        points = self->readPointsSection(nPoints, type)
      end
      'vertices' : begin
        nVertices = long(sectionTokens[1])
        size = long(sectionTokens[2])
        vertices = self->readConnectivityListSection(nVertices, size)        
      end
      'lines' :  begin
        nLines = long(sectionTokens[1])
        size = long(sectionTokens[2])
        lines = self->readConnectivityListSection(nLines, size)
      end
      'polygons' : begin
        nPolygons = long(sectionTokens[1])
        size = long(sectionTokens[2])
        polygons = self->readConnectivityListSection(nPolygons, size)
      end
      'triangle_strips' : begin
        nTriangleStrips = long(sectionTokens[1])
        size = long(sectionTokens[2])
        triangleStrips = self->readConnectivityListSection(nTriangleStrips, size)
        nTriangles = size - 3 * nTriangleStrips
        triangles = lonarr(4 * nTriangles)
        i = 0
        j = 0
        while (i lt n_elements(triangleStrips) - 1L) do begin
          list = triangleStrips[i + 1:triangleStrips[i] + i]
          result = [[lonarr(triangleStrips[i]) + 3L], $
                    [shift(list, 2)], $
                    [shift(list, 1)], $
                    [list]]
          result = reform(transpose(result[2:*, *]), 4L * (triangleStrips[i] - 2L))
          triangles[j] = result
          j += 4L * (triangleStrips[i] - 2L)
          i += triangleStrips[i] + 1
        endwhile
      end
      '' :   ; skip blank lines
      else : begin  ; if we don't recognize the next line, we've read too far
        done = 1B
        self->putBackLine, sectionLine
      end
    endcase
  endwhile

  if (n_elements(polygons) gt 0) then begin
    self.dataset = obj_new('IDLgrPolygon', points, polygons=polygons)
  endif

  if (n_elements(lines) gt 0) then begin
    self.dataset = obj_new('IDLgrPolyline', points, polylines=lines)
  endif

  if (n_elements(triangles) gt 0) then begin
    self.dataset = obj_new('IDLgrPolygon', points, polygons=triangles)
  endif
end


pro mgffserialvtk::readTextureCoordinatesAttribute, nPoints, dataName, dim, $
    dataType
  compile_opt strictarr

  texCoords = make_array(nPoints * dim, type=dataType)
  self->getData, texCoords

  texCoords = reform(texCoords, dim, nPoints)
  self.dataset->setProperty, texture_coord=texCoords, color=[255, 255, 255]
end


pro mgffserialvtk::readVectorsAttribute, nPoints, dataName, dataType
  compile_opt strictarr

  nDimensions = 3L
  vectors = make_array(nPoints * nDimensions, type=type)
  self->getData, vectors

  vectors = reform(vectors, nDimensions, nPoints)
  ; TODO: what to do with this vector?
end


pro readScalarsAttribute, nPoints, dataName, dataType, numComp
  compile_opt strictarr

  lookupTableLine = self->getLine()
  lookupTableTokens = strsplit(lookupTableLine, /extract)
  
  if (strlowcase(lookupTableTokens[0]) eq 'lookup_table') then begin
    tableName = lookupTableTokens[1]
    lookupTable = make_array(nPoints, type=dataType)
    self->getData, lookupTable
    ; TODO: what to do with this table?
  endif else self->putBackLine, lookupTableLine
end


pro mgffserialvtk::readNormalsAttribute, nPoints, dataName, dataType
  compile_opt strictarr

  nDimensions = 3L
  normals = make_array(nPoints * nDimensions, type=type)
  self->getData, normals

  normals = reform(normals, nDimensions, nPoints)
  self.dataset->setProperty, normals=normals
end


pro mgffserialvtk::readCellData, nCells
  compile_opt strictarr

  done = 0B

  while (~eof(self.lun) && ~done) do begin
    attributeLine = self->getLine()
    attributeTokens = strsplit(attributeLine, /extract)

    case strlowcase(attributeTokens[0]) of
      'scalars' :       ; not implemented yet
      'color_scalars' :   ; not implemented yet
      'lookup_table' :   ; not implemented yet
      'vectors' :   ; not implemented yet
      'normals' :   ; not implemented yet
      'texture_coordinates' :   ; not implemented yet
      'tensors' :   ; not implemented yet
      'field' :   ; not implemented yet
      '' :   ; skip blank lines
      else : begin
        done = 1B
        self->putBackLine, attributeLine
      end
    endcase
  endwhile
end


pro mgffserialvtk::readPointData, nPoints
  compile_opt strictarr

  done = 0B

  while (~eof(self.lun) && ~done) do begin
    attributeLine = self->getLine()
    attributeTokens = strsplit(attributeLine, /extract)
    
    case strlowcase(attributeTokens[0]) of
      'scalars' : begin
        dataName = attributeTokens[1]
        dataType = self->convertVtkTypeToIdlType(attributeTokens[2])
        numComp = n_elements(attributeTokens) gt 3 $                  
                  ? long(attributeTokens[3]) $
                  : 1L
        self->readScalarsAttribute, nPoints, dataName, dataType, numComp
      end
      'color_scalars' :   ; not implemented yet
      'lookup_table' :   ; not implemented yet
      'vectors' : begin
        dataName = attributeTokens[1]
        dataType = self->convertVtkTypeToIdlType(attributeTokens[2])
        self->readVectorsAttribute, nPoints, dataName, dataType
      end
      'normals' : begin
        dataName = attributeTokens[1]
        dataType = self->convertVtkTypeToIdlType(attributeTokens[2])
        self->readNormalsAttribute, nPoints, dataName, dataType
      end
      'texture_coordinates' : begin
        dataName = attributeTokens[1]
        dim = long(attributeTokens[2])
        dataType = self->convertVtkTypeToIdlType(attributeTokens[3])
        self->readTextureCoordinatesAttribute, nPoints, dataName, dim, dataType
      end
      'tensors' :   ; not implemented yet
      'field' :   ; not implemented yet
      '' :   ; skip blank lines
      else : begin
        done = 1B
        self->putBackLine, attributeLine
      end
    endcase
  endwhile
end


pro mgffserialvtk::readDataset, datasetType
  compile_opt strictarr

  case strlowcase(datasetType) of
    'structured_points' :   ; not implemented
    'structured_grid' :   ; not implemented
    'rectilinear_grid' :   ; not implemented
    'polydata' : self->readPolydataDataset
    'unstructured_grid' :   ; not implemented
    'field' :   ; not sure if this is possible
  endcase
end


pro mgffserialvtk::readTopLevelLine
  compile_opt strictarr

  topLevelLine = self->getLine()
  lineTokens = strsplit(topLevelLine, /extract)

  case strlowcase(lineTokens[0]) of
    'dataset' : self->readDataset, lineTokens[1]
    'point_data' : self->readPointData, long(lineTokens[1])
    'cell_data' : self->readCellData, long(lineTokens[1])
    '' :   ; ignore blank lines 
    else :   ; error
  endcase
end


function mgffserialvtk::read
  compile_opt strictarr

  while (~eof(self.lun)) do begin
    self->readTopLevelLine
  endwhile

  return, self.dataset
end


;+
; Read version line, header line, and file format line.
;-
pro mgffserialvtk::readHeader
  compile_opt strictarr
  on_error, 2

  versionLine = ''
  readf, self.lun, versionLine
  self.version = stregex(versionLine, '[0-9.]+', /extract)

  header = ''
  readf, self.lun, header
  self.header = header

  fileType = ''
  readf, self.lun, fileType
  case strlowcase(fileType) of
    'ascii' : self.binary = 0B
    'binary' : self.binary = 1B
    else : message, 'Invalid file type: ' + fileType
  endcase
end


;+
; Converts a VTK type into an IDL type code.
;
; :Returns:
;    integer
;
; :Params:
;    vtkType : in, required, type=string
;       one of the VTK types: bit, unsigned_char, char, unsigned_short, short,
;       unsigned_int, int, unsigned_long, long, float, double
;-
function mgffserialvtk::convertVtkTypeToIdlType, vtkType
  compile_opt strictarr
  on_error, 2

  case strlowcase(vtkType) of
    'bit' : message, 'Unsupported type: bit'
    'unsigned_char' : return, 1
    'char' :  message, 'Unsupported type: char'
    'unsigned_short' : return, 12
    'short' : return, 2
    'unsigned_int' : return, 13
    'int' : return, 3
    'unsigned_long' : return, 15
    'long' : return, 14
    'float' : return, 4
    'double' : return, 5
    else: message, 'Unsupported type: ' + vtkType
  endcase
end


pro mgffserialvtk::putBackLine, line
  compile_opt strictarr
  on_error, 2

  if (self.haveLine) then begin
    message, 'Internal error: Can''t put back a line when one is already present.'
  endif

  self.haveLine = 1B
  self.line = line
end


function mgffserialvtk::getLine
  compile_opt strictarr

  if (self.haveLine) then begin
    self.haveLine = 0B
    return, self.line
  endif else begin
    line = ''
    readf, self.lun, line
    return, line
  endelse
end


;+
; Reads any already dimensioned variable.
; 
; :Params: 
;    data : in, out, required, type=any
;       IDL variable type to be used with READU or READF
;-
pro mgffserialvtk::getData, data
  compile_opt strictarr

  if keyword_set(self.binary) then begin
    readu, self.lun, data
  endif else begin
    readf, self.lun, data
  endelse  
end


;+
; Get properties of the object.
; 
; :Keywords:
;    version : out, optional, type=string
;       version of the VTK data file
;    file_type : out, optional, type=string
;       either ASCII or BINARY
;    header : out, optional, type=string
;       comments about file
;-
pro mgffserialvtk::getProperty, version=version, file_type=fileType, $
                                header=header
  compile_opt strictarr

  version = self.version
  fileType = keyword_set(self.binary) ? 'BINARY' : 'ASCII'
  header = self.header
end


;+
; Free resources of object.
;-
pro mgffserialvtk::cleanup
  compile_opt strictarr

  free_lun, self.lun
end



;+
; Initialize object.
;
; :Returns:
;    1 for success, 0 for failure
;
; :Params: 
;    filename : in, required, type=string
;       filename of VTK serial data file
;-
function mgffserialvtk::init, filename, _extra=e
  compile_opt strictarr

  openr, lun, filename, /get_lun, _strict_extra=e
  self.lun = lun

  self->readHeader

  return, 1
end


;+
; Define member variables for the class.
;
; :Fields:
;    version 
;       VTK data file version
;-
pro mgffserialvtk__define
  compile_opt strictarr

  define = { MGffSerialVTK, $
             version: '', $
             header: '', $
             binary: 0B, $
             lun : 0L, $
             line: '', $
             haveLine: 0B, $
             dataset : obj_new() $
           }
end
