; docformat = 'rst'

;+
; Determine if a dimension name is in use and what its identifier is.
;
; :Private:
;
; :Returns:
;   dimension identifier if dimension name found, -1 otherwise
;
; :Params:
;   file_id : in, required, type=long
;     identifier for netCDF file open for writing
;   dim_name : in, required, type=string
;     potential dimension name
;
; :Keywords:
;   found : out, optional, type=boolean
;     set to a named variable to return whether the dimension name was found
;-
function mg_nc_putdata_checkdimname, file_id, dim_name, found=found
  compile_opt strictarr

  ; annoying to have to do all this, but NCDF_DIMID will print an error message
  ; when dim_name is not found otherwise

  found = 0B
  catch, error
  if (error ne 0L) then begin
    catch, /cancel
    !quiet = old_quiet
    return, -1
  endif

  old_quiet = !quiet
  !quiet = 1
  id = ncdf_dimid(file_id, dim_name)
  !quiet = old_quiet
  found = id lt 0L ? 0B : 1B

  return, id
end


;+
; Put a variable into an open netCDF file with a given name.
;
; :Private:
;
; :Params:
;   parent_id : in, required, type=long
;     parent/group identifier
;   varname : in, required, type=string
;     name of variable
;   data : in, required, type=numeric
;     data to store in variable
;
; :Keywords:
;   dim_names : in, optional, type=strarr
;     string array of dimension names
;   error : out, optional, type=long
;     set to a named variable to return error status
;-
pro mg_nc_putdata_putvariable, parent_id, varname, data, $
                               dim_names=dim_names, error=error
  compile_opt strictarr

  catch, error
  if (error ne 0L) then begin
    catch, /cancel
    return
  endif

  var_ids = ncdf_varidsinq(parent_id)
  variable_id = -1L
  if (var_ids[0] ne -1L) then begin
    for v = 0L, n_elements(var_ids) - 1L do begin
      var_info = ncdf_varinq(parent_id, var_ids[v])
      if (var_info.name eq varname) then begin
        variable_id = var_ids[v]
        break
      endif
    endfor
  endif

  if (variable_id eq -1L) then begin
    ; create dimensions as needed
    dims = size(data, /dimensions)
    n_dims = size(data, /n_dimensions)
    dim_ids = lonarr(n_dims)

    for i = 0L, n_dims - 1L do begin
      if (i ge n_elements(dim_names)) then begin
        dim_ids[i] = ncdf_dimdef(parent_id, $
                                 varname + '_' + strtrim(i, 2), $
                                 dims[i])
      endif else begin
        dim_ids[i] = mg_nc_putdata_checkdimname(parent_id, dim_names[i], found=found)
        if (~found) then begin
          dim_ids[i] = ncdf_dimdef(parent_id, dim_names[i], dims[i])
        endif
      endelse
    endfor
  
    type = size(data, /type)
    variable_id = ncdf_vardef(parent_id, $
                              varname, $
                              dim_ids, $
                              ubyte=type eq 1, $
                              short=type eq 2, $
                              long=type eq 3, $
                              float=type eq 4, $
                              double=type eq 5, $
                              string=type eq 7, $
                              ushort=type eq 12, $
                              ulong=type eq 13)
  endif

  ncdf_varput, parent_id, variable_id, data
end


;+
; Put an attribute into an open netCDF file with a given name.
;
; :Private:
;
; :Params:
;   file_id : in, required, type=long
;     identifier for netCDF file open for writing
;   parent_id : in, required, type=long
;     identifier for parent group/variable
;   attname : in, required, type=string
;     name of attribute
;   data : in, required, type=numeric
;     data to store in attribute
;
; :Keywords:
;   error : out, optional, type=long
;     set to a named variable to return error status
;-
pro mg_nc_putdata_putattribute, file_id, parent_id, attname, data, error=error
  compile_opt strictarr

  catch, error
  if (error ne 0L) then begin
    catch, /cancel
    return
  endif

  type = size(data, /type)

  if (file_id eq parent_id) then begin
    ncdf_attput, file_id, attname, data, /global, $
                 ubyte=type eq 1, $
                 short=type eq 2, $
                 long=type eq 3, $
                 float=type eq 4, $
                 double=type eq 5, $
                 string=type eq 7, $
                 ushort=type eq 12, $
                 ulong=type eq 13, $
                 uint64=type eq 15
    
  endif else begin
    ncdf_attput, file_id, parent_id, attname, data, $
                 ubyte=type eq 1, $
                 short=type eq 2, $
                 long=type eq 3, $
                 float=type eq 4, $
                 double=type eq 5, $
                 string=type eq 7, $
                 ushort=type eq 12, $
                 ulong=type eq 13, $
                 uint64=type eq 15
  endelse
end


;+
; Routine for writing netCDF files.
;
; :Params:
;   filename : in, required, type=string
;     filename of file to write to; this file does not need to exist beforehand
;   descriptor : in, required, type=string
;     name of variable/attribute to write
;   data : in, required, type=any
;     data to write
;
; :Keywords:
;   dim_names : in, optional, type=strarr
;     string array of dimension names
;   error : out, optional, type=long
;     error code, 0 for no errors
;-
pro mg_nc_putdata, filename, descriptor, data, dim_names=dim_names, error=error
  compile_opt strictarr
  on_error, 2

  error = 0L

  ; create an new netCDF file if it doesn't already exist
  if (file_test(filename)) then begin
    file_id = ncdf_open(filename, /write)
  endif else begin
    file_id = ncdf_create(filename, /netcdf4_format)
  endelse

  type = mg_nc_decompose(file_id, descriptor, $
                         parent_type=parent_type, $
                         parent_id=parent_id, $
                         group_id=group_id, $
                         element_name=element_name, $
                         /write, error=error)
  if (error ne 0L) then return

  case type of
    0: begin
        error = -1L
        message, 'unknown descriptor type', /informational
      end
    1: begin
         case parent_type of
           2: mg_nc_putdata_putattribute, group_id, parent_id, $
                                          element_name, data, $
                                          error=error
           3: begin
               if (parent_id eq file_id) then begin
                 mg_nc_putdata_putattribute, file_id, parent_id, $
                                             element_name, data, $
                                             error=error
               endif else begin
                 mg_nc_putdata_putattribute, parent_id, parent_id, $
                                             element_name, data, $
                                             error=error
                 ;error = -1L
                 ;message, 'attributes on groups not allowed', /informational
               endelse
             end
           else: begin
               error = -1L
               message, 'invalid parent type', /informational
             end
         endcase
         if (error) then message, 'error writing attribute', /informational
      end
    2: begin
         mg_nc_putdata_putvariable, parent_id, element_name, data, $
                                    dim_names=dim_names, error=error
         if (error) then message, 'error writing variable', /informational
      end
    3: begin
        message, 'unable to create group from descriptor', /informational
      end
    else: begin
        error = -1L
        message, 'unknown descriptor type', /informational
      end
  endcase

  ncdf_close, file_id
end


; main-level example program

filename = 'test.nc'

mg_nc_putdata, filename, 'x', findgen(10, 20), error=error
mg_nc_putdata, filename, 'y', dindgen(10), error=error
mg_nc_putdata, filename, 'z', lindgen(10), error=error

help, error

mg_nc_dump, filename

end
