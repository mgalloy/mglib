; docformat = 'rst'

;+
; Return array of element names.
;
; :Returns:
;   `strarr` or `!null` if none found
;
; :Params:
;   filename : in, required, type=string
;     filename of the netCDF file
;   path : in, required, type=string
;     path for variable/attribute name (with path if inside a group)
;
; :Keywords:
;   attributes : in, optional, type=boolean
;     set to return attribute names
;   groups : in, optional, type=boolean
;     set to return group names
;   variables : in, optional, type=boolean
;     set to return variable names
;   error : out, optional, type=long
;     error value, 0 indicates success
;-
function mg_nc_list, filename, path, $
                     attributes=attributes, $
                     groups=groups, $
                     variables=variables, $
                     count=count, $
                     error=error
  compile_opt strictarr
  on_error, 2

  error = 0L
  file_id = ncdf_open(filename, /nowrite)

  count = 0L
  result = !null

  _path = n_elements(path) eq 0L ? '/' : path

  type = mg_nc_decompose(file_id, _path, $
                         parent_type=parent_type, $
                         parent_id=parent_id, $
                         group_id=group_id, $
                         element_name=element_name, $
                         /write, error=error)
  if (error ne 0L) then return, !null

  case type of
    1: begin  ; attribute
        error = -1L
        message, 'no children of attributes', /informational
      end
    2: begin  ; variable
        var_id = element_name eq '' $
                   ? parent_id $
                   : ncdf_varid(parent_id, element_name)
        case 1 of
          keyword_set(attributes): begin
              info = ncdf_varinq(group_id, var_id)

              count = info.natts
              if (count eq 0L) then begin
                result = !null
              endif else begin
                result = strarr(count)
                for a = 0L, count - 1L do begin
                  result[a] = ncdf_attname(group_id, var_id, a)
                endfor
              endelse
            end
          keyword_set(groups):
          keyword_set(variables):
          else: begin
              message, 'ATTRIBUTES, GROUPS, or VARIABLES must be set'
            end
        endcase
      end
    3: begin  ; group
        group_id = element_name eq '' $
                     ? parent_id $
                     : ncdf_ncidinq(parent_id, element_name)
        case 1 of
          keyword_set(attributes): begin
              info = ncdf_inquire(group_id)
              count = info.ngatts
              if (count eq 0L) then begin
                result = !null
              endif else begin
                result = strarr(count)
                for a = 0L, count - 1L do begin
                  result[a] = ncdf_attname(group_id, a, /global)
                endfor
              endelse
            end
          keyword_set(groups): begin
              group_ids = ncdf_groupsinq(group_id)

              if (group_ids[0] eq -1L) then begin
                result = !null
              endif else begin
                count = n_elements(group_ids)
                result = strarr(count)
                for g = 0L, count - 1L do begin
                  result[g] = ncdf_groupname(group_ids[g])
                endfor
              endelse
            end
          keyword_set(variables): begin
              var_ids = ncdf_varidsinq(group_id)

              if (var_ids[0] eq -1L) then begin
                result = !null
              endif else begin  
                count = n_elements(var_ids)
                result = strarr(count)
                for v = 0L, count - 1L do begin
                  var_info = ncdf_varinq(group_id, var_ids[v])
                  result[v] = var_info.name
                endfor
              endelse
            end
          else: begin
              message, 'ATTRIBUTES, GROUPS, or VARIABLES must be set'
            end
        endcase
      end
    else: begin
        error = -1L
        message, 'unknown path descriptor type', /informational
      end
  endcase

  ncdf_close, file_id

  return, result
end