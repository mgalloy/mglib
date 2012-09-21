; docformat = 'rst'

;+
; Parent class for POV-Ray specific graphics classes. Classes that inherit
; from this class use specific POV-Ray functionality not available in IDL.
; 
; :Private:
;
; :Categories:
;    object graphics
;-

;+
; Convert an RGB 3-element byte array to a POV-Ray string specifying the 
; color, like [255, 0, 0] to '<1.0, 0.0, 0.0>'.
; 
; :Private:
; 
; :Returns:
;    POV-Ray string representation of a color
;
; :Params:
;    color : in, required, type=bytarr(3)
;       object graphics style color
;
; :Keywords:
;     alpha_channel : in, optional, type=float
;        value from 0.0 (completely transparent) to 1.0 (completely opaque)
;     filter : in, optional, type=boolean
;        set to use filter transparency instead of transmittance or 
;        non-filtering transparency
;-
function visgrpovrayobject::_getRgb, color, alpha_channel=alphaChannel, $
                                     filter=filter
  compile_opt strictarr

  if (n_elements(alphaChannel) gt 0L) then begin
    a = 1.0 - alphaChannel
    if (keyword_set(filter)) then begin    
      return, 'rgbf <' + strjoin(strtrim([float(color) / 255.0, a], 2), ', ') + '>'
    endif else begin
      return, 'rgbt <' + strjoin(strtrim([float(color) / 255.0, a], 2), ', ') + '>'
    endelse
  endif else begin
    return, 'rgb <' + strjoin(strtrim(float(color) / 255.0, 2), ', ') + '>' 
  endelse
end


;+
; Write the matrix property of the POV-Ray object (the current transformation
; matrix of the object graphics object).
;
; :Private:
; 
; :Params:
;    lun : in, required, type=long
;       logical unit number to write to
;    transform : in, required, type="fltarr(4, 4)"
;       object graphics transformation matrix
;-
pro visgrpovrayobject::_writeTransform, lun, transform
  compile_opt strictarr

  ; transformation in POV-Ray eliminates the bottom row since it doesn't give
  ; any information
  matrix = transpose((transform)[*, 0:2])
  
  printf, lun
  printf, lun, '  matrix <' + strjoin(strtrim(matrix[*, 0], 2), ',') + ','
  printf, lun, '          ' + strjoin(strtrim(matrix[*, 1], 2), ',') + ','
  printf, lun, '          ' + strjoin(strtrim(matrix[*, 2], 2), ',') + ','
  printf, lun, '          ' + strjoin(strtrim(matrix[*, 3], 2), ',') + '>'  
end


;+
; Write a list of vertices to the open output file.
;
; :Private:
; 
; :Params:
;    lun : in, required, type=long
;       lun for output file
;    vertices : in, required, type="fltarr(n, 3)"
;       vertices data
;
; :Keywords:
;    name : in, required, type=string
;       name of section
;-
pro visgrpovrayobject::_writeVertices, lun, vertices, name=name
  compile_opt strictarr

  nVertices = (size(vertices, /dimensions))[1]
  
  printf, lun, '  ' + name + ' {'
  printf, lun, '    ' + strtrim(nVertices, 2) + ','
  
  for v = 0L, nVertices - 2L do begin
    printf, lun, '    <' + strjoin(strtrim(vertices[*, v], 2), ',') + '>,'
  endfor
  
  printf, lun, '    <' + strjoin(strtrim(vertices[*, v], 2), ',') + '>'

  printf, lun, '  }'  
end


;+
; Initialize VISgrPOVRayObject.
;-
function visgrpovrayobject::init
  compile_opt strictarr

  self.lightIntensityMultiplier = 1.75
  
  return, 1
end


;+
; Define instance variables.
;
; :Fields:
;    lightIntensityMultiplier
;       conversion factor to convert IDL light intensity to a POV-Ray light
;       intensity
;-
pro visgrpovrayobject__define
  compile_opt strictarr
  
  define = { VISgrPOVRayObject, $
             lightIntensityMultiplier: 0.0 $
           }
end
