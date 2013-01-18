; docformat = 'rst'

;+
; :Categories:
;    file i/o, hdf5, sdf
;
; :Requires:
;    IDL 8.0
;
; :Author:
;    Michael Galloy
;
; :Properties:
;    filename
;       filename of the HDF 5 file
;-


;+
; Get properties
;-
pro mgffh5file::getProperty, filename=filename, _ref_extra=e
  compile_opt strictarr

  if (arg_present(filename)) then filename = self.filename
  if (n_elements(e) gt 0L) then self->MGffH5Base::getProperty, _extra=e
end


;+
; Dumps the contents of the file.
;-
pro mgffh5file::dump
  compile_opt strictarr

  mg_h5_dump, self.filename
end


;+
; Start the HDF 5 browser on the file.
;-
pro mgffh5file::browse
  compile_opt strictarr

  ok = h5_browser(self.filename)
end


;+
; Open an HDF 5 file.
;
; :Private:
;
; :Keywords:
;    error : out, optional, type=long
;       error code: 0 for none
;-
pro mgffh5file::_open, error=error
  compile_opt strictarr

  catch, error
  if (error ne 0L) then begin
    catch, /cancel
    return
  endif

  self.id = h5f_open(self.filename)
end


;+
; Close an HDF 5 file.
;
; :Private:
;
; :Keywords:
;    error : out, optional, type=long
;       error code: 0 for none
;-
pro mgffh5file::_close, error=error
  compile_opt strictarr

  catch, error
  if (error ne 0L) then begin
    catch, /cancel
    return
  endif

  h5f_close, self.id
end


;+
; Get object info for child object inside file.
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
function mgffh5file::_statObject, name, error=error
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
; Output for `HELP` for file.
;
; :Private:
;
; :Returns:
;    string
;
; :Params:
;    varname : in, required, type=string
;       name of variable containing group object
;-
function mgffh5file::_overloadHelp, varname
  compile_opt strictarr

  type = 'H5File'
  specs = string(self.filename, format='(%"<%s>")')
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
function mgffh5file::_overloadPrint
  compile_opt strictarr

  ; TODO: show group name, not filename

  nmembers = h5g_get_num_objs(self.id)
  names = strarr(nmembers)
  types = strarr(nmembers)
  for g = 0L, nmembers - 1L do begin
    names[g] = h5g_get_obj_name_by_idx(self.id, g)
    info = h5g_get_objinfo(self.id, names[g])
    types[g] = info.type
  endfor

  listing = mg_strmerge('  ' + names + ' (' + strlowcase(types) + ')')
  return, string(self.filename, listing, format='(%"HDF5 file: %s\n%s")')
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
function mgffh5file::_overloadBracketsRightSide, isRange, $
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
; Free resources of the HDF 5 file, including its children.
;-
pro mgffh5file::cleanup
  compile_opt strictarr

  obj_destroy, self.children
  self->_close
end


;+
; Creates HDF 5 object.
;
; :Returns:
;    1 for success, 0 for failure
;-
function mgffh5file::init, filename=filename, _extra=e
  compile_opt strictarr
  on_error, 2

  if (~self->MGffH5Base::init(_extra=e)) then return, 0

  self.filename = n_elements(filename) eq 0L ? '' : filename
  self.children = obj_new('IDL_Container')
  self.name = ''

  self->_open, error=error
  if (error ne 0L) then message, 'invalid HDF5 file'

  return, 1
end


;+
; Define instance variables and class inheritance.
;
; :Fields:
;    filename
;       name of HDF 5 file
;    children
;       `IDL_Container` of children group/dataset objects
;-
pro mgffh5file__define
  compile_opt strictarr

  define = { MGffH5File, inherits MGffH5Base, $
             filename: '', $
             children: obj_new() $
           }
end


; main-level example program

print, format='(%"\nUsing an HDF5 file:")'
h = mgffh5file(filename=file_which('hdf5_test.h5'))
help, h
print, h

print, format='(%"\nUsing a group:")'
g1 = h['images']
help, g1
print, g1

print, format='(%"\nUsing a dataset:")'
d = h['2D int array']
help, d

print, format='(%"\nUsing a dataset:")'
e = g1['eskimo']
help, e
help, size(e, /structure), /structures
window, /free, xsize=600, ysize=200, title='Eskimo profile'
plot, e[*, 400], xstyle=9, ystyle=8
print, e['IMAGE_COLORMODEL'], format='(%"IMAGE_COLORMODEL attribute = %s")'

ct = g1['eskimo_palette']
tvlct, transpose(ct[*])
device, get_decomposed=odec
device, decomposed=0
dims = size(e, /dimensions)
window, /free, xsize=dims[0], ysize=dims[1], title='Eskimo image'
tv, e[*], order=1
device, decomposed=odec

end
