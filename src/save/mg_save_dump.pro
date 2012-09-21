; docformat = 'rst'

;+
; Display a listing of the contents of a `.sav` file.
;
; :Params:
;    filename : in, required, type=string
;       filename of a `.sav` file
;
; :Keywords:
;    verbose : in, optional, type=boolean
;       set to display information about file such as description, system type
;       and IDL version where file was created, etc.
;-
pro mg_save_dump, filename, verbose=verbose
  compile_opt strictarr
  resolve_routine, 'mg_variable_declaration', $
                   /compile_full_file, /is_function, /no_recompile
  
  sfile = obj_new('IDL_savefile', filename)
  info = sfile->contents()

  if (keyword_set(verbose)) then begin
    print, info.user, info.host, info.date, format='(%"Created by %s@%s on %s")'
    print, info.release, info.os, info.arch, format='(%"Created with IDL %s on %s.%s")'
    print, info.description, format='(%"Description: %s")'
    print, info.filetype, format='(%"Type: %s")'
  
    print
  endif
    
  if (info.n_procedure + info.n_function gt 0L) then begin
    print, info.n_procedure, info.n_function, format='(%"Procedures: %d, functions: %d")'
  endif else if (info.n_var + info.n_sysvar + info.n_object_heapvar $
                   + info.n_pointer_heapvar + info.n_structdef $
                   + info.n_common gt 0L) then begin

    ndigits = long(alog10(info.n_var > info.n_sysvar > info.n_object_heapvar $
                            > info.n_pointer_heapvar > info.n_structdef $
                            > info.n_common)) + 1L
    format = string(ndigits, format='(%"(\%\"\%-22s \%%dd\")")')

    if (info.n_var gt 0L) then begin
      print, 'Variables:', info.n_var, format=format
    endif
    
    if (info.n_sysvar gt 0L) then begin
      print, 'System variables:', info.n_sysvar, format=format
    endif

    if (info.n_object_heapvar gt 0L) then begin
      print, 'Objects:', info.n_object_heapvar, format=format
    endif

    if (info.n_pointer_heapvar gt 0L) then begin
      print, 'Pointers:', info.n_pointer_heapvar, format=format
    endif

    if (info.n_structdef gt 0L) then begin
      print, 'Structure definitions:', info.n_structdef, format=format
    endif

    if (info.n_common gt 0L) then begin
      print, 'Common blocks:', info.n_common, format=format
    endif
  endif else begin
    print, 'No variables or routines found'
  endelse

  if (info.n_var gt 0L) then begin
    print
    print, 'Variables'
    print, '---------'
    
    var_names = sfile->names()
    foreach n, var_names do begin
      sfile->restore, n
      print, n, mg_variable_declaration(scope_varfetch(n)), $
             format='(%"%s = %s")'
    endforeach
  endif

  if (info.n_sysvar gt 0L) then begin
    print
    print, 'System variables'
    print, '----------------'
    
    sysvar_names = sfile->names(/system_variable)
    foreach n, sysvar_names do begin
      sfile->restore, n
      print, n, mg_variable_declaration(scope_varfetch(n)), $
             format='(%"%s = %s")'
    endforeach
  endif
  
  if (info.n_object_heapvar gt 0L) then begin
    print
    print, 'Objects'
    print, '-------'
    
    obj_names = sfile->names(/object_heapvar)
    foreach n, obj_names do begin
      sfile->restore, n, /object_heapvar, new_heapvar=var
      print, n, mg_variable_declaration(var), format='(%"ObjHeapVar%d = %s")'
    endforeach
  endif
    
  if (info.n_pointer_heapvar gt 0L) then begin
    print
    print, 'Pointers'
    print, '--------'
    
    ptr_names = sfile->names(/pointer_heapvar)
    foreach n, ptr_names do begin
      sfile->restore, n, /pointer_heapvar, new_heapvar=var
      print, n, mg_variable_declaration(var), format='(%"PtrHeapVar%d = %s")'
    endforeach
  endif

  if (info.n_structdef gt 0L) then begin
    print
    print, 'Structure definitions'
    print, '---------------------'
    
    sdef_names = sfile->names(/structure_definition)
    foreach n, sdef_names do begin
      sfile->restore, n, /structure_definition
      print, mg_variable_declaration(create_struct(name=n)), $
             format='(%"%s")'
    endforeach
  endif
  
  if (info.n_common gt 0L) then begin
    print
    print, 'Common blocks'
    print, '-------------'
    
    commonblock_names = sfile->names(/common_block)
    foreach n, commonblock_names do begin
      print, n, strjoin(commonblockvar_names, ', '), format='(%"%s: %s")'
    endforeach
  endif

  if (info.n_function gt 0L) then begin
    print
    print, 'Functions'
    print, '---------'
    
    function_names = sfile->names(/function)
    foreach n, function_names do begin
      print, n, format='(%"result = %s(...)")'
    endforeach
  endif

  if (info.n_procedure gt 0L) then begin
    print
    print, 'Procedures'
    print, '----------'
    
    procedure_names = sfile->names(/procedure)
    foreach n, procedure_names do begin
      print, n, format='(%"%s")'
    endforeach
  endif
          
  obj_destroy, sfile
end


; main-level example

cow_filename = file_which('cow10.sav')
mg_save_dump, cow_filename

end

