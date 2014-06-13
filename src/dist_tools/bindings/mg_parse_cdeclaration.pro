; docformat = 'rst'

;+
; Parses a variable declaration from a C prototype.
;
; :Private:
;-


;+
; Parses a variable or routine declaration into a name and type declaration.
; For example, it splits the following::
;
;   char *IDL_OutputFormatFunc
;
; into the type "char *" and `NAME` "IDL_OutputFormatFunc".
;
; :Returns:
;   `SIZE` type code or C string declaration
;
; :Params:
;   decl : in, required, type=string
;     C declaration
;
; :Keywords:
;   name : out, optional, type=string
;     routine/parameter name
;   pointer : out, optional, type=boolean
;     pass a named variable to get whether the declaration is a pointer (but
;     not an array)
;   array : out, optional, type=boolean
;     pass a named variable to get whether the declaration is an array (but
;     not a pointer)
;   device : out, optional, type=boolean
;     pass a named variable to get whether the declaration is a device
;     pointer/array
;-
function mg_parse_cdeclaration, decl, name=name, $
                                pointer=pointer, $
                                array=array, $
                                device=device
  compile_opt strictarr

  _decl = strtrim(decl, 2)

  loc = strsplit(_decl, ' *', count=ntokens, length=len)
  device = strmid(_decl, 0, len[0]) eq 'device'

  type_start = device ? loc[1] : 0
  type_len = loc[ntokens - 1L] - (device ? loc[1] : 0)
  type = strtrim(strmid(_decl, type_start, type_len), 2)
  name = strmid(_decl, loc[ntokens - 1L])

  pointer = 0B
  array = strmid(_decl, strlen(_decl) - 2) eq '[]'

  ; TODO: handle case with no space between type and *, like "int*"

  case type of
    'void': return, 0L
    'char': return, 1L
    'UCHAR': return, 1L
    'short int': return, 2L
    'IDL_INT': return, 2L
    'int': return, 3L
    'IDL_LONG': return, 3L
    'float': return, 4L
    'double': return, 5L
    'IDL_COMPLEX': return, 6L
    'char *': return, 7L
    'IDL_DCOMPLEX': return, 9L
    'unsigned short int': return, 12L
    'IDL_UINT': return, 12L
    'unsigned int': return, 13L
    'IDL_ULONG': return, 13L
    'long': return, 14L
    'IDL_LONG64': return, 14L
    'unsigned long': return, 15L
    'IDL_ULONG64': return, 15L
    'void *': begin
      pointer = 1B
      return, 0L
    end
    'UCHAR *': begin
      pointer = 1B
      return, 1L
    end
    'short int *': begin
      pointer = 1B
      return, 2L
    end
    'IDL_INT *': begin
      pointer = 1B
      return, 2L
    end
    'int *': begin
      pointer = 1B
      return, 3L
    end
    'IDL_LONG *': begin
      pointer = 1B
      return, 3L
    end
    'float *': begin
      pointer = 1B
      return, 4L
    end
    'double *': begin
      pointer = 1B
      return, 5L
    end
    'IDL_COMPLEX *': begin
      pointer = 1B
      return, 6L
    end
    'IDL_DCOMPLEX *': begin
      pointer = 1B
      return, 9L
    end
    'unsigned short int *': begin
      pointer = 1B
      return, 12L
    end
    'IDL_UINT *': begin
      pointer = 1B
      return, 12L
    end
    'unsigned int *': begin
      pointer = 1B
      return, 13L
    end
    'IDL_ULONG *': begin
      pointer = 1B
      return, 13L
    end
    'long *': begin
      pointer = 1B
      return, 14L
    end
    'IDL_LONG64 *': begin
      pointer = 1B
      return, 14L
    end
    'unsigned long *': begin
      pointer = 1B
      return, 15L
    end
    'IDL_ULONG64 *': begin
      pointer = 1B
      return, 15L
    end
    else: begin
        if (strmid(type, 0, 1, /reverse_offset) eq '*') then begin
          pointer = 1B
          return, 0L
        endif else begin
          return, type
        endelse
      end
  endcase
end
