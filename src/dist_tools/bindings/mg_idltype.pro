; docformat = 'rst'

;+
; Converts `SIZE` type codes to various C codes/names needed in DLM.
;
; :Private:
;-


;+
; Return the `IDL_ALLTYPES` member field name for a given type.
;
; :Private:
;
; :Returns:
;   string
;
; :Params:
;   type_code : in, required, type=long
;     `SIZE` type code
;
; :Keywords:
;   pointer : in, optional, type=boolean
;     set to indicate a pointer to the type
;-
function mg_idltype_tmp_fieldname, type_code, pointer=pointer
  compile_opt strictarr

  if (size(type_code, /type) eq 7 || keyword_set(pointer)) then begin
    return, 'ptrint'
  endif

  case type_code of
     0: return, ''
     1: return, 'c'
     2: return, 'i'
     3: return, 'l'
     4: return, 'f'
     5: return, 'd'
     6: return, 'cmp'
     7: return, 'str'
     8: return, 's'
     9: return, 'dcmp'
    10: return, 'hvid'
    11: return, 'hvid'
    12: return, 'ui'
    13: return, 'ul'
    14: return, 'l64'
    15: return, 'ul64'
  endcase
end


;+
; Return the `IDL_ALLTYPES` member declaration type for a given type.
;
; :Private:
;
; :Returns:
;   string
;
; :Params:
;   type_code : in, required, type=long
;     `SIZE` type code
;-
function mg_idltype_declaration, type_code
  compile_opt strictarr

  if (size(type_code, /type) eq 7) then begin
    return, type_code
  endif

  case type_code of
     0: return, ''
     1: return, 'UCHAR'
     2: return, 'IDL_INT'
     3: return, 'IDL_LONG'
     4: return, 'float'
     5: return, 'double'
     6: return, 'IDL_COMPLEX'
     7: return, 'IDL_STRING_s'
     8: return, 'IDL_SREF'
     9: return, 'IDL_DCOMPLEX'
    10: return, 'IDL_HVID'
    11: return, 'IDL_HVID'
    12: return, 'IDL_UINT'
    13: return, 'IDL_ULONG'
    14: return, 'IDL_LONG64'
    15: return, 'IDL_ULONG64'
  endcase
end


;+
; Return the `SIZE` type code C constant name for a given type.
;
; :Private:
;
; :Returns:
;   string
;
; :Params:
;   type_code : in, required, type=long
;     `SIZE` type code
;-
function mg_idltype_type, type_code
  compile_opt strictarr

  if (size(type_code, /type) eq 7) then begin
    _type_code = strtrim(type_code, 2)
    if (strmid(_type_code, strlen(_type_code) - 1) eq '*') then begin
      return, 'IDL_TYP_PTRINT'
    endif

    return, 'CUSTOM_C_TYPE'
  endif

  case type_code of
     0: return, 'IDL_TYP_UNDEF'
     1: return, 'IDL_TYP_BYTE'
     2: return, 'IDL_TYP_INT'
     3: return, 'IDL_TYP_LONG'
     4: return, 'IDL_TYP_FLOAT'
     5: return, 'IDL_TYP_DOUBLE'
     6: return, 'IDL_TYP_COMPLEX'
     7: return, 'IDL_TYP_STRING'
     8: return, 'IDL_TYP_STRUCT'
     9: return, 'IDL_TYP_DCOMPLEX'
    10: return, 'IDL_TYP_PTR'
    11: return, 'IDL_TYP_OBJREF'
    12: return, 'IDL_TYP_UINT'
    13: return, 'IDL_TYP_ULONG'
    14: return, 'IDL_TYP_LONG64'
    15: return, 'IDL_TYP_ULONG64'
  endcase
end


;+
; Return the temp variable retriever for a given type.
;
; :Private:
;
; :Returns:
;   string
;
; :Params:
;   type_code : in, required, type=long
;     `SIZE` type code
;-
function mg_idltype_tmp_routine, type_code
  compile_opt strictarr

  case type_code of
     0: return, 'IDL_Gettmp'
     1: return, 'IDL_GettmpByte'
     2: return, 'IDL_GettmpInt'
     3: return, 'IDL_GettmpLong'
     4: return, 'IDL_GettmpFloat'
     5: return, 'IDL_GettmpDouble'
     6: return, 'MG_GettmpComplex'
     7: return, 'IDL_StrToSTRING'
     8: return, 'IDL_TYP_STRUCT'
     9: return, 'MG_GettmpDComplex'
    10: return, 'IDL_GettmpPtr'
    11: return, 'IDL_GettmpObjRef'
    12: return, 'IDL_GettmpUInt'
    13: return, 'IDL_GettmpULong'
    14: return, 'IDL_GettmpLong64'
    15: return, 'IDL_GettmpULong64'
  endcase
end


;+
; Converts a `SIZE` type code into various C declaration names. By default, it
; converts into the `IDL_ALLTYPES` member field name.
;
; :Returns:
;   string
;
; :Params:
;   type_code : in, required, type=long
;     `SIZE` type code
;
; :Keywords:
;   declaration : in, optional, type=boolean
;     set to get the `IDL_ALLTYPES` field name's declaration type
;   type : in, optional, type=boolean
;     set to get the `SIZE` type code C constant name
;   pointer : in, optional, type=boolean
;     set to indicate a pointer to the type
;   tmp_routine : in, optional, type=boolean
;     set to return the name of the routine to get a temporary variable of that
;     type
;-
function mg_idltype, type_code, $
                     declaration=declaration, $
                     type=type, $
                     pointer=pointer, $
                     tmp_routine=tmp_routine
  compile_opt strictarr

  case 1 of
    keyword_set(type):        return, mg_idltype_type(type_code)
    keyword_set(declaration): return, mg_idltype_declaration(type_code)
    keyword_set(tmp_routine): return, mg_idltype_tmp_routine(type_code)
    else:                     return, mg_idltype_tmp_fieldname(type_code, pointer=pointer)
  endcase
end
