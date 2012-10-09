; docformat = 'rst'

;+
; Converts `SIZE` type codes to various C codes/names needed in DLM.
;
; :Private:
;-


;+
; Converts a `SIZE` type code into various C declaration names. By default, it
; converts into the `IDL_ALLTYPES` member field name.
;
; :Returns:
;    string
;
; :Params:
;    type_code : in, required, type=long
;       `SIZE` type code
;
; :Keywords:
;    declaration : in, optional, type=boolean
;       set to get the `IDL_ALLTYPES` field name's declaration type
;    type : in, optional, type=boolean
;       set to get the `SIZE` type code C constant name
;-
function mg_idltype, type_code, declaration=declaration, type=type
  compile_opt strictarr

  case 1 of
    keyword_set(type): begin
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
    keyword_set(declaration): begin
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
    else: begin
      if (size(type_code, /type) eq 7) then begin
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
  endcase
end
