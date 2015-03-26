; docformat = 'rst'

;+
; Finds the routines (normal functions and procedures) needed for the code
; inside a file, i.e., the routines it calls, the routines those routines call,
; etc.
;
; :Bugs:
;   Because `RESOLVE_ALL` is called to compile all the routines called from
;   within the given routine, `RESOLVE_ALL` is always present in the resolved
;   routines. It and its helper `UNIQ` are removed from the output (but may
;   actually be present).
;
; :Returns:
;   string array of routine names
;
; :Params:
;   file : in, required, type=string
;     file basename without the `.pro` extension to resolve for called
;     routines
;
; :Keywords:
;   count : out, optional, type=long
;     number of called routines found
;   bridge : in, out, optional, type=object
;     IDL_IDLBridge object used to resolve routines; if a bridge is not
;     passed in, one is created; if a named variable is passed, the bridge
;     object will be passed back to the caller, otherwise the bridge is
;     destroyed
;-
function mg_called_routines, file, count=count, bridge=bridge
  compile_opt strictarr

  ignores = ['RESOLVE_ALL', 'RESOLVE_ALL_BODY', 'RESOLVE_ALL_CLASS', $
             '$MAIN$', 'UNIQ']
  filename = file + '.pro'

  bridge = obj_valid(bridge) ? bridge : obj_new('IDL_IDLBridge')

  cd, current=current

  bridge->execute, string(current, format='(%"cd, ''%s''")')
  bridge->execute, '.reset_session'
  bridge->execute, string(file, format='(%"resolve_routine, ''%s'', /either")')
  bridge->execute, 'resolve_all'
  bridge->execute, 'help, /source, /full, output=output'

  output = bridge->getVar('output')

  if (~arg_present(bridge)) then obj_destroy, bridge

  count = 0L
  continued = 0B
  routines = ['']

  for i = 0L, n_elements(output) - 1L do begin
    if (strpos(output[i], 'Compiled Procedures:') eq 0L) then continue
    if (strpos(output[i], 'Compiled Functions:') eq 0L) then continue
    if (output[i] eq '') then continue

    if (strmid(output[i], 0, 1) eq ' ') then begin
      basename = file_basename(strtrim(output[i], 2))

      ; ignore helper routines in the same file
      if (basename eq filename) then begin
        ; don't need to ignore routines in the ignore list (they have already)
        ; been ignored
        if (ignoreCount eq 0L) then begin
          routines = routines[0:--count]
        endif
      endif
    endif else begin
      tokens = strsplit(output[i], count=ntokens, /extract)
      ind = where(tokens[0] eq ignores, ignoreCount)
      if (ignoreCount eq 0L) then begin
        routines = [routines, tokens[0]]
        count++
        if (ntokens eq 2L) then begin
          basename = file_basename(strtrim(tokens[1], 2))
          if (basename eq filename) then routines = routines[0:--count]
        endif
      endif
    endelse
  endfor

  return, count eq 0L ? -1L : routines[1:*]
end


; main-level example program

r = ['mg_called_routines', 'idldoc', 'idldoc_version', 'man']

for i = 0L, n_elements(r) - 1L do begin
  routines = mg_called_routines(r[i], count=count, bridge=bridge)
  if (count eq 0L) then begin
    print, r[i], format='(%"No routines needed by %s")'
  endif else begin
    print, count, r[i], strjoin(routines, ', '), $
           format='(%"%d routines needed for %s: %s")'
  endelse
endfor

obj_destroy, bridge

end
