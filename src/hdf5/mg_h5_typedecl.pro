; docformat = 'rst'

;+
; Helper routine to convert an HDF 5 data type to an IDL variable 
; declaration.
;
; :Private:
;-


;+
; Converts an HDF 5 data type to an IDL variable declaration.
; 
; :Private:
;
; :Returns:
;    string
;
; :Params:
;    dataType : in, required, type=long
;       IDL SIZE code for datatype
;-
function mg_h5_typedecl, dataType
  compile_opt strictarr
  
  types = ['UNDEFINED', 'BYTE', 'INT', 'LONG', 'FLOAT', 'DOUBLE', $
           'COMPLEX', 'STRING', 'STRUCTURE', 'DCOMPLEX', 'POINTER', $
           'OBJREF', 'UINT', 'ULONG', 'LONG64', 'ULONG64']
  return, types[dataType]
end
