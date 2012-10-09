; docformat = 'rst'

;+
; Convenience wrapper for `BREAKPOINT` that finds files in `!path` without
; having to use a full path specification.
;-


;+
; Finds the path to a given routine.
;
; :Private:
;
; :Returns:
;    string
;
; :Params:
;    name : in, required, type=string
;       routine name
;-
function mg_breakpoint_getpath, name
  compile_opt strictarr

  flag = 0

  catch, error
  if (error ne 0L) then begin
    flag++
    if (flag gt 1L) then return, ''
    info = routine_info(name, /source, /function)
    return, info.path
  endif

  info = routine_info(name, /source)

  return, info.path
end


;+
; A helpful wrapper for `BREAKPOINT` which finds files in the `!path` and
; allows relative line numbers within routines.
;
; :Todo:
;    fix up line number when `ROUTINE` keyword is set
;
; :Params:
;    name : in, required, type=string
;       name of file (with or without the .pro extension) or routine (when the
;       `ROUTINE` keyword is set)
;    line : in, required, type=integer
;       line number with the file (normally) or routine (when `ROUTINE`
;       keyword is set)
;
; :Keywords:
;    routine : in, optional, type=boolean
;       set to specify a routine name and a line number within the routine
;       definition
;    _extra : in, optional, type=keywords
;       keywords to `BREAKPOINT`
;-
pro mg_breakpoint, name, line, routine=routine, _extra=e
  compile_opt strictarr
  on_error, 2

  if (keyword_set(routine)) then begin
    _name = mg_breakpoint_getpath(name)
    if (_name eq '') then message, 'routine not found'

    nlines = file_lines(_name)
    file = strarr(nlines)
    openr, lun, _name, /get_lun
    readf, lun, file
    free_lun, lun

    re = string(name, format='(%"^[[:space:]]*(pro|function)[[:space:]]+%s([[:space:]]+|$)")')
    match = stregex(file, re, /fold_case, /boolean)
    ind = where(match, count)

    if (count gt 0L) then begin
      _line = ind[0] + line + 1L
    endif else begin
      message, 'routine not found'
    endelse
  endif else begin
    ; add .pro extension if it is missing
    _name = strmid(name, 3, 4, /reverse_offset) eq '.pro' $
              ? name $
              : (name + '.pro')

    ; find in !path if not in the current directory
    _name = file_test(_name) ? _name : file_which(_name)
    if (_name eq '') then message, 'file not found'

    _line = line
  endelse

  breakpoint, _name, _line, _extra=e
end
