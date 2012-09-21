; docformat = 'rst'

;+
; Routine to resolve a given routine without crashing.
;
; :Examples:
;    For example, try::
;
;       IDL> mg_resolve_routine, 'mg_src_root', resolved=resolved, /either
;       IDL> help, resolved
;       RESOLVED        BYTE      =    1
;       IDL> mg_resolve_routine, 'mg_fake_routine', resolved=resolved, /either
;       IDL> help, resolved                                                         
;       RESOLVED        BYTE      =    0
;
;    Note that `RESOLVE_ROUTINE` would have crashed in the second call to
;    `MG_RESOLVE_ROUTINE`.
;
; :Params:
;    routine : in, required, type=string
;       name of routine to resolve
;
; :Keywords:
;    resolved : out, optional, type=boolean
;       set to a named variable to find out if the routine was resolved
;    _extra : in, optional, type=keywords
;       keywords to `RESOLVE_ROUTINE`
;-
pro mg_resolve_routine, routine, resolved=resolved, _extra=e
  compile_opt strictarr, hidden

  oldQuiet = !quiet
  !quiet = 1
  
  resolved = 0B
    
  catch, error
  if (error ne 0L) then begin
    catch, /cancel
    !quiet = oldQuiet
    return
  endif
  
  ; resolving the currently executing routine is a problem, but if you are
  ; executing the routine it has already been resolved
  if (strlowcase(routine) ne 'mg_resolve_routine') then begin
    resolve_routine, routine, _extra=e
  endif
  
  resolved = 1B
  
  !quiet = oldQuiet
end
