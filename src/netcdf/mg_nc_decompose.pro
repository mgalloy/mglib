; docformat = 'rst'

;+
; Wrapper for `NCDF_VARID` so that messages are not displayed.
;
; :Private:
;
; :Params:
;   parent_id : in, required, type=long
;     identifier for parent group
;   varname : in, required, type=string
;     variable name
;-
function mg_nc_varid, parent_id, varname
  compile_opt strictarr

  old_quiet = !quiet
  !quiet = 1
  var_id = ncdf_varid(parent_id, varname)
  !quiet = old_quiet

  return, var_id
end


;+
; Determines the type of element described by `descriptor`, i.e., invalid (0),
; attribute (1), variable (2), or group (3).
;
; Note: this routine will create required groups if `WRITE` is set.
;
; :Returns:
;   element type code as a long
;
; :Params:
;   file_id : in, required, type=long
;     netCDF file identifier, should be open for writing if `WRITE` is set
;   descriptor : in, required, type=string
;     string description of attribute, variable, or group
;
; :Keywords:
;   parent_type : out, optional, type=long
;     element type code for parent element, can only 2 or 3
;   parent_id : out, optional, type=long
;     netCDF identifier for parent element
;   element_name : out, optional, type=string
;     name of the element being described
;   write : in, optional, type=boolean
;     set to create required groups in file (attributes or variables are not
;     created by this routine)
;   error : out, optional, type=long
;     set to a named variable to return the error status, 0 indicates no error
;-
function mg_nc_decompose, file_id, descriptor, $
                          parent_type=parent_type, $
                          parent_id=parent_id, $
                          group_id=group_id, $
                          element_name=element_name, $
                          write=write, $
                          error=error
  compile_opt strictarr

  catch, error
  if (error ne 0L) then begin
    catch, /cancel
    return, 0L
  endif

  has_attribute = 0B

  ; use STRSPLIT instead of STRPOS to handle escapes
  dotpos = strsplit(descriptor, '.', escape='\', count=n_dots, /preserve_null)
  n_dots--
  dotpos = n_dots gt 0L ? (dotpos[-1] - 1L) : -1L

  if (dotpos ne -1L) then begin
    has_attribute = 1B
    group_descriptor = dotpos eq 0L ? '/' : strmid(descriptor, 0, dotpos)
  endif else begin
    group_descriptor = descriptor
  endelse

  group_id = file_id

  if (group_descriptor eq '/') then begin
    if (has_attribute) then begin
      parent_type = 3L
      parent_id = file_id
      element_name = strmid(descriptor, dotpos + 1)
      return, 1L
    endif else begin
      parent_type = 3L
      parent_id = file_id
      element_name = ''
      return, 3L
    endelse
  endif else begin
    groups = strsplit(group_descriptor, '/', /extract, count=n_groups)

    for i = 0L, n_groups - 2L do begin
      new_group_id = ncdf_ncidinq(group_id, groups[i])

      ; create group if it doesn't already exist (and WRITE is set)
      if (new_group_id eq -1L) then begin
        if (keyword_set(write)) then begin
          group_id = ncdf_groupdef(group_id, groups[i])
        endif else begin
          return, 0L
        endelse
      endif else begin
        group_id = new_group_id
      endelse
    endfor
  endelse

  ; last "group" could be a group or variable

  ; check to see if last "group" is a variable
  var_id = mg_nc_varid(group_id, groups[-1])
  if (var_id ne -1L) then begin
    if (has_attribute) then begin
      parent_type = 2L
      parent_id = var_id
      element_name = strmid(descriptor, dotpos + 1)
      return, 1L
    endif else begin
      parent_type = 3L
      parent_id = group_id
      element_name = groups[-1]
      return, 2L
    endelse
  endif

  ; check to see if last "group" is actually a group
  new_group_id = ncdf_ncidinq(group_id, groups[-1])
  if (new_group_id ne -1L) then begin
    if (has_attribute) then begin
      parent_type = 3L
      parent_id = new_group_id
      element_name = strmid(descriptor, dotpos + 1)
      return, 1L
    endif else begin
      parent_type = 3L
      parent_id = group_id
      element_name = groups[-1]
      return, 3L
    endelse
  endif

  ; last "group" undefined so far
  if (has_attribute) then begin
    if (keyword_set(write)) then begin
      group_id = ncdf_groupdef(group_id, groups[i])
      parent_type = 3L
      parent_id = group_id
      element_name = strmid(descriptor, dotpos + 1)
      return, 1L
    endif else begin
      return, 0L
    endelse
  endif else begin
    parent_type = 3L
    parent_id = group_id
    element_name = groups[-1]
    return, 2L
  endelse

  ; problem if control reaches here
  return, 0L
end
