; docformat = 'rst'

;+
; Creates a list of files required to run the specified routines.
;
; :Todo:
;    handle `HELP` output where routine and filename are not on the same line 
;    because the routine name is too long
; 
; :Params:
;    routines : in, required, type=string/strarr
;       routine or routines that are required
;    outdir : in, optional, type=string
;       directory to copy files to, if present
;
; :Keywords:
;    class : in, optional, type=string/strarr
;       class(es) to compile
;-
pro mg_use, routines, outdir, class=class
  compile_opt strictarr

  ; resolve routines
  resolve_routine, routines, /either
  resolve_all, class=class
  resolve_all
  
  ; get a listing of all the source files
  procedures = routine_info(/source)
  functions = routine_info(/source, /functions)
  nprocedures = size(procedures, /type) eq 7L ? 0: n_elements(procedures)
  nfunctions = size(functions, /type) eq 7L ? 0: n_elements(functions)
  
  ; remove $MAIN$ from procedures
  if (nprocedures gt 1L) then procedures = procedures[1:*]
  nprocedures--
  
  ; get a combined listing of filenames
  case 1 of
    nprocedures gt 0L && nfunctions gt 0L: filenames = [procedures.path, functions.path]
    nprocedures gt 0L && nfunctions eq 0L: filenames = procedures.path
    nprocedures eq 0L && nfunctions gt 0L: filenames = functions.path
    nprocedures eq 0L && nfunctions eq 0L: return
  endcase
    
  ; eliminate source files in the IDL lib directory
  libdir = filepath('lib')
  libfiles = where(strpos(filenames, libdir) eq 0L, nlibfiles)
  if (nlibfiles gt 0L) then begin
    all = bytarr(n_elements(filenames))
    all[libfiles] = 1B
    
    nonlibfiles = where(all eq 0B, nnonlibfiles)
    if (nnonlibfiles gt 0L) then begin
      filenames = filenames[nonlibfiles]
    endif else return
  endif

  ; eliminate duplicates
  uniqElements = uniq(filenames, sort(filenames))
  filenames = filenames[uniqElements]  
  
  ; eliminate MG_USE
  if (n_elements(filenames) eq 1L) then return
  filenames = filenames[where(file_basename(filenames) ne 'mg_use.pro')]
  
  ; eliminate MG_USE_WRAPPER, if present
  validInd = where(file_basename(filenames) ne 'mg_use_wrapper.pro', nvalid)
  if (nvalid gt 0L) then filenames = filenames[validInd] else return
    
  ; print or copy
  if (n_elements(outdir) eq 0L) then begin
    print, n_elements(filenames) eq 1L ? filenames : transpose(filenames)
  endif else begin
    if (~file_test(outdir, /directory)) then file_mkdir, outdir
    file_copy, filenames, outdir, /allow_same, /overwrite
  endelse
end
