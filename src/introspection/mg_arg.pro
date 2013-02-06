; docformat = 'rst'


;+
; Handle an argument to a routine.
;
; :Returns:
;   argument value
;-
function mg_arg, arg, default=default, error=error, $
                 types=types, $
                 ensure_array=ensure_array, $
                 ensure_scalar=ensure_scalar, $
                 ensure_simple=ensure_simple
  compile_opt strictarr
  on_error, 2

  name = scope_varname(arg, level=-1L)
  error = 0L

  type = size(arg, /type)

  if (n_elements(arg) gt 0L && n_elements(types) gt 0L) then begin
    ind = where(type eq types, type_matched)
    if (type_matched eq 0B) then begin
      if (arg_present(error)) then begin
        error = 1L
        return, !null
      endif else begin
        message, string(name, type, format='(%"invalid type for %s: %d")')
      endelse
    endif
  endif

  if (keyword_set(ensure_array)) then begin
    if (size(arg, /n_dimensions) eq 0L) then begin
      if (arg_present(error)) then begin
        error = 1L
        return, !null
      endif else begin
        message, string(name, format='(%"%s not an array")')
      endelse
    endif
  endif

  if (keyword_set(ensure_scalar)) then begin
    if (size(arg, /n_dimensions) ne 0L) then begin
      if (arg_present(error)) then begin
        error = 1L
        return, !null
      endif else begin
        message, string(name, format='(%"%s not a scalar")')
      endelse
    endif
  endif

  if (keyword_set(ensure_simple)) then begin
    if (type eq 8L || type eq 10L || type eq 11 || size(arg, /file_lun) ne 0L) then begin
      if (arg_present(error)) then begin
        error = 1L
        return, !null
      endif else begin
        message, string(name, format='(%"%s not simple")')
      endelse
    endif
  endif

  return, n_elements(arg) eq 0L $
            ? (n_elements(default) eq 0L ? !null : default) $
            : arg
end

