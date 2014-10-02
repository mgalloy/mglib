; docformat = 'rst'

;+
; Return a listing of the contents of a `.sav` file.
;
; :Returns:
;   `strarr` or `!null` if no contents
;
; :Params:
;   filename : in, required, type=string
;     filename of a `.sav` file
;
; :Keywords:
;   all : in, optional, type=boolean
;     set to return all items regardless of type
;-
function mg_save_list, filename, $
                       all=all, $
                       variables=variables, $
                       system_variables=system_variables, $
                       object_heapvars=object_heapvars, $
                       pointer_heapvars=pointer_heapvars, $
                       structure_definitions=structure_definitions, $
                       common_blocks=common_blocks, $
                       functions=functions, $
                       procedures=procedures, $
                       count=count, error=error
  compile_opt strictarr

  error = 0L
  sfile = obj_new('IDL_savefile', filename)
  info = sfile->contents()

  names = list()

  if ((info.n_var gt 0L) && (keyword_set(all) || keyword_set(variables))) then begin
    names->add, sfile->names()
  endif

  if ((info.n_sysvar gt 0L) && (keyword_set(all) || keyword_set(system_variables))) then begin
    names->add, sfile->names(/system_variable)
  endif

  if ((info.n_object_heapvar gt 0L) && (keyword_set(all) || keyword_set(object_heapvars))) then begin
    names->add, sfile->names(/object_heapvar)
  endif

  if ((info.n_pointer_heapvar gt 0L) && (keyword_set(all) || keyword_set(pointer_heapvars))) then begin
    names->add, sfile->names(/pointer_heapvar)
  endif

  if ((info.n_structdef gt 0L) && (keyword_set(all) || keyword_set(structure_definitions))) then begin
    names->add, sfile->names(/structure_definition)
  endif

  if ((info.n_common gt 0L) && (keyword_set(all) || keyword_set(common_blocks))) then begin
    names->add, sfile->names(/common_block)
  endif

  if ((info.n_function gt 0L) && (keyword_set(all) || keyword_set(functions))) then begin
    names->add, sfile->names(/function)
  endif

  if ((info.n_procedure gt 0L) && (keyword_set(all) || keyword_set(procedures))) then begin
    names->add, sfile->names(/procedure)
  endif

  obj_destroy, sfile
  names_array = names->toArray()
  count = names->count()
  obj_destroy, names
  return, names_array
end


; main-level example

cow_filename = file_which('cow10.sav')
print, mg_save_list(cow_filename, /all)

end

