; docformat = 'rst'

;+
; Helper routine to convert an GRIB data type to an IDL variable
; declaration.
;
; :Private:
;
; :Categories:
;   file i/o, grib, sdf
;-


;+
; Converts an GRIB data type to an IDL variable declaration.
;
; :Private:
;
; :Returns:
;   string
;
; :Params:
;   code : in, required, type=integer
;     `SIZE` code of GRIB variable
;
; :Keywords:
;   suffix : in, optional, type=boolean
;     set to return suffix, i.e., B, S, L, D, etc.
;-
function mg_grib_typedecl, code, suffix=suffix
  compile_opt strictarr

  if (keyword_set(suffix)) then begin
    case code of
      0: return, ''
      1: return, 'B'
      2: return, 'S'
      3: return, 'L'
      4: return, ''
      5: return, 'D'
      7: return, ''
      12: return, 'US'
      13: return, 'UL'
      14: return, 'LL'
      15: return, 'ULL'
      else: return, ''
    endcase
  endif else begin
    case code of
      0: return, '<undefined>'
      1: return, 'bytarr'
      2: return, 'intarr'
      3: return, 'lonarr'
      4: return, 'fltarr'
      5: return, 'dblarr'
      7: return, 'strarr'
      12: return, 'uintarr'
      13: return, 'ulonarr'
      14: return, 'lon64arr'
      15: return, 'ulon64arr'
      else: return, '<unknown>'
    endcase
  endelse
end
