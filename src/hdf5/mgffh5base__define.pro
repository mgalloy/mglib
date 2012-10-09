; docformat = 'rst'

;+
; Common functionality for HDF 5 classes.
;
; :Properties:
;    parent
;       parent MGffH5 object
;    identifier
;       HDF 5 identifier for object
;    name
;       name of the object
;-


;+
; Get properties.
;-
pro mgffh5base::getProperty, parent=parent, identifier=identifier, $
                             name=name, fullname=fullname
  compile_opt strictarr

  if (arg_present(parent)) then parent = self.parent
  if (arg_present(identifier)) then identifier = self.id
  if (arg_present(name)) then name = self.name
  if (arg_present(fullname)) then begin
    if (obj_valid(self.parent)) then begin
      self.parent->getProperty, fullname=fullname
      fullname += '/' + self.name
    endif else fullname = self.name
  endif
end


;+
; HELP overload common routine.
;
; :Params:
;    varname : in, required, type=string
;       name of variable to provide HELP for
;
; :Keywords:
;    type : in, optional, type=string, default='NC_BASE'
;       type for object
;    specs : in, optional, type=string, default='<undefined>'
;       specs for object, depending on object type
;-
function mgffh5base::_overloadHelp, varname, type=type, specs=specs
  compile_opt strictarr

  _type = n_elements(type) eq 0L ? 'H5_BASE' : type
  _specs = n_elements(specs) eq 0L ? '<undefined>' : specs

  return, string(varname, _type, _specs, format='(%"%-15s %-9s = %s")')
end


;+
; Creates HDF 5 object.
;
; :Returns:
;    1 for success, 0 for failure
;-
function mgffh5base::init, parent=parent, identifier=identifier, name=name
  compile_opt strictarr
  on_error, 2

  self.parent = n_elements(parent) eq 0L ? obj_new() : parent
  self.id = n_elements(identifier) eq 0L ? '' : identifier
  self.name = n_elements(name) eq 0L ? '' : name

  return, 1
end


;+
; Define instance variables and class inheritance.
;
; :Fields:
;    id
;       HDF 5 identifier for object
;-
pro mgffh5base__define
  compile_opt strictarr

  define = { MGffH5Base, inherits IDL_Object, $
             parent: obj_new(), $
             id: 0L, $
             name: '' $
           }
end
