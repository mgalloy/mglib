; docformat = 'rst'

;+
; Object representing an HDF 5 group.
;
; :Categories: 
;    file i/o, hdf5, sdf
;
; :Requires:
;    IDL 8.0
;
; :Author:
;    Michael Galloy
;-


;+
; Get properties
;-
pro mgffh5group::getProperty, _ref_extra=e
  compile_opt strictarr

  if (n_elements(e) gt 0L) then self->MGffH5Base::getProperty, _extra=e
end


;+
; Open an HDF 5 group.
;
; :Private:
; 
; :Keywords:
;    error : out, optional, type=long
;       error code: 0 for none
;-
pro mgffh5group::_open, error=error
  compile_opt strictarr

  catch, error
  if (error ne 0L) then begin
    catch, /cancel
    return
  endif
  
  self.parent->getProperty, identifier=parent_id
  self.id = h5g_open(parent_id, self.name)
end


;+
; Close an HDF 5 group.
;
; :Private:
; 
; :Keywords:
;    error : out, optional, type=long
;       error code: 0 for none
;-
pro mgffh5group::_close, error=error
  compile_opt strictarr

  catch, error
  if (error ne 0L) then begin
    catch, /cancel
    return
  endif
  
  h5g_close, self.id
end


;+
; Get object info for child object inside group.
;
; :Private:
; 
; :Params:
;    name : in, required, type=string
;       name of child object
;
; :Keywords:
;    error : out, optional, type=long
;       error code: 0 for none
;-
function mgffh5group::_statObject, name, error=error
  compile_opt strictarr

  catch, error
  if (error ne 0L) then begin
    catch, /cancel
    return, -1
  endif

  for i = 0L, h5g_get_num_objs(self.id) - 1L do begin
    ; find first case-insensitive match
    objName = h5g_get_obj_name_by_idx(self.id, i)
    if (strcmp(objName, name, /fold_case)) then begin
      name = objName
      break
    endif
  endfor
      
  return, h5g_get_objinfo(self.id, name)
end


;+
; Output for `HELP` for group.
;
; :Returns:
;    string
; 
; :Params:
;    varname : in, required, type=string
;       name of variable containing group object
;-
function mgffh5group::_overloadHelp, varname
  compile_opt strictarr

  type = 'H5Group'
  self->getProperty, fullname=fullname
  specs = string(fullname, format='(%"%s")')
  return, self->MGffH5Base::_overloadHelp(varname, type=type, specs=specs)
end


;+
; Output for `PRINT` for group.
;
; :Private:
;
; :Returns:
;    string
;-
function mgffh5group::_overloadPrint
  compile_opt strictarr

  self->_open, error=error
  if (error ne 0L) then message, 'invalid HDF5 file'
  
  nmembers = h5g_get_num_objs(self.id)
  names = strarr(nmembers)
  types = strarr(nmembers)
  for g = 0L, nmembers - 1L do begin
    names[g] = h5g_get_obj_name_by_idx(self.id, g)    
    info = h5g_get_objinfo(self.id, names[g])
    types[g] = info.type
  endfor
  
  ; TODO: show attributes as well

  listing = mg_strmerge('  ' + types + ' ' + names)

  return, string(self.name, mg_newline(), listing, format='(%"GROUP %s%s%s")')
end


;+
; Handles accessing groups/variables, particularly those with case-sensitive
; names or spaces/other characters in their names.
; 
; :Private:
;
; :Examples:
;    For example::
; 
;       h = mg_h5(file_which('hdf5_test.h5'))
;       d = h['2D int array']
;-
function mgffh5group::_overloadBracketsRightSide, isRange, $
                                                  ss1, ss2, ss3, ss4, $
                                                  ss5, ss6, ss7, ss8
  compile_opt strictarr
  on_error, 2
  
  objInfo = self->_statObject(ss1, error=error)
  if (error ne 0L) then message, string(ss1, format='(%"object %s not found")')

  ; TODO: search existing children before creating a new one
  
  case objInfo.type of
    'GROUP': result = obj_new('MGffH5Group', parent=self, name=ss1)
    'DATASET': result = obj_new('MGffH5Dataset', parent=self, name=ss1)
    'TYPE': ; TODO: implement
    'LINK': ; TODO: implement
    'UNKNOWN': message, string(ss1, format='(%"object %s unknown")')
    else: begin
        ; TODO: check for attribute
        message, string(ss1, format='(%"object %s unknown")')
      end
  endcase
  
  self.children->add, result
  
  if (n_elements(ss2) gt 0L) then begin
    return, result->_overloadBracketsRightSide(isRange[1:*], ss2, ss3, ss4, ss5, ss6, ss7, ss8)
  endif else begin
    return, result
  endelse  
end


;+
; Free resources.
;-
pro mgffh5group::cleanup
  compile_opt strictarr
  
  obj_destroy, self.children
  self->_close
end


;+
; Create a group object.
;
; :Returns:
;    1 for success, 0 for failure
;-
function mgffh5group::init, _extra=e
  compile_opt strictarr
  on_error, 2
  
  if (~self->MGffH5Base::init(_extra=e)) then return, 0
  
  self.children = obj_new('IDL_Container')

  self->_open, error=error
  if (error ne 0L) then message, 'invalid HDF5 group'
  
  return, 1
end


;+
; Define instance variables and class inheritance.
;
; :Fields:
;    children
;       `IDL_Container` containing children groups/datasets
;-
pro mgffh5group__define
  compile_opt strictarr
  
  define = { MGffH5Group, inherits MGffH5Base, $
             children: obj_new() $
           }
end
