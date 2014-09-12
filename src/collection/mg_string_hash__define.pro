; docformat = 'rst'

;+
; Definition of mg_string_hash class.
;
; :Properties:
;   _extra
;     properties from hash
;
; :Author:
;   Michael D. Galloy
;-


;= Operator overloading methods


pro mg_string_hash::_overloadBracketsLeftSide, o, val, is_range, ss1, ss2, $
                                               ss3, ss4, ss5, ss6, ss7, ss8
  compile_opt strictarr
  on_error, 2

  if (n_elements(ss1) ne 0L) then begin
    if (size(ss1, /type) ne 7) then begin
      message, 'non-string key'
    endif else _ss1 = keyword_set(self.fold_case) ? strlowcase(ss1) : ss1
  endif

  if (n_elements(ss2) ne 0L) then begin
    if (size(ss2, /type) ne 7) then begin
      message, 'non-string key'
    endif else _ss2 = keyword_set(self.fold_case) ? strlowcase(ss2) : ss2
  endif

  if (n_elements(ss3) ne 0L) then begin
    if (size(ss3, /type) ne 7) then begin
      message, 'non-string key'
    endif else _ss3 = keyword_set(self.fold_case) ? strlowcase(ss3) : ss3
  endif

  if (n_elements(ss4) ne 0L) then begin
    if (size(ss4, /type) ne 7) then begin
      message, 'non-string key'
    endif else _ss4 = keyword_set(self.fold_case) ? strlowcase(ss4) : ss4
  endif

  if (n_elements(ss5) ne 0L) then begin
    if (size(ss5, /type) ne 7) then begin
      message, 'non-string key'
    endif else _ss5 = keyword_set(self.fold_case) ? strlowcase(ss5) : ss5
  endif

  if (n_elements(ss6) ne 0L) then begin
    if (size(ss6, /type) ne 7) then begin
      message, 'non-string key'
    endif else _ss6 = keyword_set(self.fold_case) ? strlowcase(ss6) : ss6
  endif

  if (n_elements(ss7) ne 0L) then begin
    if (size(ss7, /type) ne 7) then begin
      message, 'non-string key'
    endif else _ss7 = keyword_set(self.fold_case) ? strlowcase(ss7) : ss7
  endif

  if (n_elements(ss8) ne 0L) then begin
    if (size(ss8, /type) ne 7) then begin
      message, 'non-string key'
    endif else _ss8 = keyword_set(self.fold_case) ? strlowcase(ss8) : ss8
  endif


  self->hash::_overloadBracketsLeftSide, o, val, is_range, _ss1, _ss2, $
                                         _ss3, _ss4, _ss5, _ss6, _ss7, _ss8
end


function mg_string_hash::_overloadBracketsRightSide, is_range, ss1, ss2, ss3, $
                                                     ss4, ss5, ss6, ss7, ss8
  compile_opt strictarr

  if (n_elements(ss1) ne 0L) then begin
    if (size(ss1, /type) ne 7) then begin
      message, 'non-string key'
    endif else _ss1 = keyword_set(self.fold_case) ? strlowcase(ss1) : ss1
  endif

  if (n_elements(ss2) ne 0L) then begin
    if (size(ss2, /type) ne 7) then begin
      message, 'non-string key'
    endif else _ss2 = keyword_set(self.fold_case) ? strlowcase(ss2) : ss2
  endif

  if (n_elements(ss3) ne 0L) then begin
    if (size(ss3, /type) ne 7) then begin
      message, 'non-string key'
    endif else _ss3 = keyword_set(self.fold_case) ? strlowcase(ss3) : ss3
  endif

  if (n_elements(ss4) ne 0L) then begin
    if (size(ss4, /type) ne 7) then begin
      message, 'non-string key'
    endif else _ss4 = keyword_set(self.fold_case) ? strlowcase(ss4) : ss4
  endif

  if (n_elements(ss5) ne 0L) then begin
    if (size(ss5, /type) ne 7) then begin
      message, 'non-string key'
    endif else _ss5 = keyword_set(self.fold_case) ? strlowcase(ss5) : ss5
  endif

  if (n_elements(ss6) ne 0L) then begin
    if (size(ss6, /type) ne 7) then begin
      message, 'non-string key'
    endif else _ss6 = keyword_set(self.fold_case) ? strlowcase(ss6) : ss6
  endif

  if (n_elements(ss7) ne 0L) then begin
    if (size(ss7, /type) ne 7) then begin
      message, 'non-string key'
    endif else _ss7 = keyword_set(self.fold_case) ? strlowcase(ss7) : ss7
  endif

  if (n_elements(ss8) ne 0L) then begin
    if (size(ss8, /type) ne 7) then begin
      message, 'non-string key'
    endif else _ss8 = keyword_set(self.fold_case) ? strlowcase(ss8) : ss8
  endif

  return, self->hash::_overloadBracketsRightSide(is_range, _ss1, _ss2, _ss3, $
                                                 _ss4, _ss5, _ss6, _ss7, _ss8)
end


;= Public methods


function mg_string_hash::hasKeys, keys
  compile_opt strictarr
  on_error, 2

  case 1 of
    size(keys, /type) eq 11: begin
        if (obj_isa(keys, 'list')) then begin
          nkeys = keys->count()
          if (nkeys eq 0L) then _keys = keys else begin
            _keys = keys->toArray(type=7)
            if (self.fold_case) then _keys = strlowcase(_keys)
          endelse
        endif else message, 'invalid key type'
      end
    size(keys, /type) eq 7: _keys = self.fold_case ? strlowcase(keys) : keys
    else: message, 'invalid key type'
  endcase

  return, self->hash::hasKeys()
end


;= Lifecycle methods

;+
; Initialize string hash object.
;
; :Returns:
;   1 for success, 0 for failure
;
; :Keywords:
;   fold_case : in, optional, type=boolean
;     set to do case-insensitive lookup
;   _extra : in, optional, type=keywords
;     keywords to `hash::init`
;-
function mg_string_hash::init, p1, p2, fold_case=fold_case, _extra=e
  compile_opt strictarr

  if (~self->hash::init(p1, p2, _extra=e)) then return, 0

  self.fold_case = keyword_set(fold_case)

  return, 1
end


;+
; Define instance variables.
;-
pro mg_string_hash__define
  compile_opt strictarr

  define = { mg_string_hash, inherits hash, $
             fold_case: 0B $
           }
end