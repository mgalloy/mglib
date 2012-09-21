; docformat = 'rst'

;+
; Determines the byte order of the platform running this routine.
;
; :Returns:
;    string (either 'little' or 'big') or byte if `IS_LITTLE_ENDIAN` or
;    `IS_BIG_ENDIAN` set
;
; :Keywords:
;    is_little_endian : in, optional, type=boolean
;       set to return a boolean value for whether the platform is little 
;       endian or not
;    is_big_endian : in, optional, type=boolean
;       set to return a boolean value for whether the platform is big endian 
;       or not
;-
function mg_endian, is_little_endian=isLittleEndian, is_big_endian=isBigEndian
  compile_opt strictarr, logical_predicate
  on_error, 2

  if (keyword_set(isLittleEndian) && keyword_set(isBigEndian)) then begin
    message, 'conflicting keywords'
  endif
    
  littleEndian = (byte(1, 0, 1))[0]
  
  if (keyword_set(isLittleEndian)) then return, littleEndian
  if (keyword_set(isBigEndian)) then return, ~littleEndian
  
  return,  littleEndian ? 'little' : 'big'
end