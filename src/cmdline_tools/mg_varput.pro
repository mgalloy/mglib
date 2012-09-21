; docformat = 'rst'

;+
; Copies a variable or expression to another stack level, e.g., the main-level.
;
; :Params:
;    variable : in, required, type=any
;       variable to be copied
;    varname : in, optional, type=string, default=current name
;       name of the variable in the new location; defaults to the current 
;       name if the variable is a named variable, i.e., not an expression
;
; :Keywords:
;    level : in, optional, type=long, default=1
;       level of stack to place the variable: `0` for current level, positive 
;       values denote absolute levels of the stack with `1` being the 
;       main-level, negative values being relative to the current level with
;       `-1` being the routine that called the caller of `MG_VARPUT`
;-
pro mg_varput, variable, varname, level=level
  compile_opt strictarr
  on_error, 2
  
  if (n_elements(variable) eq 0L) then message, 'variable must be defined'
  
  if (n_elements(varname) eq 0L) then begin
    if (arg_present(variable)) then begin
      _varname = scope_varname(variable, level=-1)
    endif else begin
      message, 'must provide a name for expressions'
    endelse
  endif else begin
    _varname = varname
  endelse
  
  if (n_elements(level) eq 0L) then begin
    _level = 1L
  endif else begin
    _level = level le 0L ? (level - 1L) : level
  endelse
  
  (scope_varfetch(_varname, level=_level, /enter)) = variable
end
