; docformat = 'rst'


;+
; Handle error checking arguments to a routine.
;
; :Examples:
;   Suppose you want to check the arguments of a function defined as::
;
;     ;+
;     ; Example routine.
;     ;
;     ; :Params:
;     ;   x : in, required, type=fltarr/dblarr
;     ;     x argument
;     ;   a : in, optional, type=long, default=0L
;     ;     a argument
;     ;-
;     function mg_example_routine, x, a
;
;   Defined, valid values will pass right through `MG_ARG`::
;
;     IDL> x = findgen(10)
;     IDL> a = 7L
;     IDL> _x = mg_arg(x, types=[4, 5], /ensure_array)
;     IDL> _a = mg_arg(a, default=0L, types=[3], /ensure_scalar)å
;     IDL> help, _x, _a
;     _X              FLOAT     = Array[10]
;     _A              LONG      =            7
;
;   If there is a default for a value, it will be used::
;
;     IDL> a = !null
;     IDL> _a = mg_arg(a, default=0L, types=[3], /ensure_scalar)
;     IDL> help, _a
;     _A              LONG      =            0
;
;   Errors are produced if the type is incorrect or the `ENSURE_XXXX` is not
;   satisfied::
;
;     IDL> x = !null
;     IDL> a = 6
;     IDL> _x = mg_arg(x, types=[4, 5], /ensure_array, error=error)
;     IDL> help, error
;     ERROR           LONG      =            1
;     IDL> _a = mg_arg(a, default=0L, types=[3], /ensure_scalar)
;     % MG_ARG: invalid type for A: 2
;
; :Returns:
;   argument value
;
; :Params:
;   arg : in, required, type=any
;     argument
;
; :Keywords:
;   default : in, optional, type=any
;     default value for argument
;   error : out, optional, type=long
;     set to a named variable
;   types : in, optional, type=lonarr
;     set to an array of valid type size codes
;   ensure_array : in, optional, type=boolean
;     set to indicate argument should be an array
;   ensure_scalar : in, optional, type=boolean
;     set to indicate argument should be a scalar
;   ensure_simple : in, optional, type=boolean
;     set to indicate argument should be "simple"
;-
function mg_arg, arg, $
                 default=default, $
                 error=error, $
                 types=types, $
                 ensure_array=ensure_array, $
                 ensure_scalar=ensure_scalar, $
                 ensure_simple=ensure_simple
  compile_opt strictarr
  on_error, 2

  name = scope_varname(arg, level=-1L)
  error = 0L

  _arg = n_elements(arg) eq 0L $
          ? (n_elements(default) eq 0L ? !null : default) $
          : arg

  type = size(_arg, /type)

  if (n_elements(_arg) gt 0L && n_elements(types) gt 0L) then begin
    ind = where(type eq types, type_matched)
    if (type_matched eq 0L) then begin
      if (arg_present(error)) then begin
        error = 1L
        return, !null
      endif else begin
        message, string(name, type, format='(%"invalid type for %s: %d")')
      endelse
    endif
  endif

  if (keyword_set(ensure_array)) then begin
    if (size(_arg, /n_dimensions) eq 0L) then begin
      if (arg_present(error)) then begin
        error = 1L
        return, !null
      endif else begin
        message, string(name, format='(%"%s not an array")')
      endelse
    endif
  endif

  if (keyword_set(ensure_scalar)) then begin
    if (size(_arg, /n_dimensions) ne 0L) then begin
      if (arg_present(error)) then begin
        error = 1L
        return, !null
      endif else begin
        message, string(name, format='(%"%s not a scalar")')
      endelse
    endif
  endif

  if (keyword_set(ensure_simple)) then begin
    if (type eq 8L || type eq 10L || type eq 11 || size(_arg, /file_lun) ne 0L) then begin
      if (arg_present(error)) then begin
        error = 1L
        return, !null
      endif else begin
        message, string(name, format='(%"%s not simple")')
      endelse
    endif
  endif

  return, _arg
end


; main-level example

; Suppose you want to check the arguments of a function defined as:
;
;   ;+
;   ; Example routine.
;   ;
;   ; :Params:
;   ;   x : in, required, type=fltarr/dblarr
;   ;     x argument
;   ;   a : in, optional, type=long, default=0L
;   ;     a argument
;   ;-
;   function mg_example_routine, x, a

x = findgen(10)
a = 7L
_x = mg_arg(x, types=[4, 5], /ensure_array)
_a = mg_arg(a, default=0L, types=[3], /ensure_scalar)

help, _x, _a

x = findgen(20)
a = !null
_x = mg_arg(x, types=[4, 5], /ensure_array)
_a = mg_arg(a, default=0L, types=[3], /ensure_scalar)

help, _x, _a

x = !null
a = 6
_x = mg_arg(x, types=[4, 5], /ensure_array, error=error)
help, error
_a = mg_arg(a, default=0L, types=[3], /ensure_scalar)

help, _x, _a

end
