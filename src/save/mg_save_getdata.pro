; docformat = 'rst'

;+
; Retrieve a variable from a save file.
;
; :Returns:
;   variable restored or hash containing variables if more than one variable 
;   is requested
; 
; :Params:
;    filename : in, required, type=string
;       filename of a `.sav` file
;    varname : in, required, type=string
;       name of variable to retrieve from the save file
;
; :Keywords:
;    _extra : in, optional, type=keywords
;       keywords to `IDL_Savefile::restore`
;-
function mg_save_getdata, filename, varname, _extra=e
  compile_opt strictarr
  
  savefile = obj_new('IDL_Savefile', filename=filename)
  
  case n_elements(varname) of
    0: begin
        varnames = savefile->names(count=nvarnames)
        help, nvarnames
        help, varnames
        savefile->restore, varnames, _extra=e
        result = hash()
        for v = 0L, nvarnames - 1L do begin
          result[varnames[v]] = scope_varfetch(varnames[v], /enter)
        endfor
      end
    1: begin
        savefile->restore, varname, _extra=e
        result = scope_varfetch(varname, /enter)
      end
    else: begin
        savefile->restore, varname, _extra=e
        result = hash()
        for v = 0L, n_elements(varname) - 1L do begin
          result[strupcase(varname[v])] = scope_varfetch(varname[v], /enter)          
        endfor
      end
  endcase

  obj_destroy, savefile
  
  return, result
end


; main-level example

cow_filename = file_which('cow10.sav')
polylist = mg_save_getdata(cow_filename, 'polylist')
all_vars = mg_save_getdata(cow_filename)

end
