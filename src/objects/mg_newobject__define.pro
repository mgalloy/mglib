; docformat = 'rst'

;+
; Inherit from `MG_NewObject` to be able to specify instance variables
; dynamically. For example, define an instance variable when instantiating the
; object::
;
;   o = mg_newobject(name='Mike')
;
; or later::
;
;   o.city = 'Boulder'
;
; :Requires:
;   IDL 8.5
;
; :Properties:
;   instance_variables : private, type=hash
;     hash of instance variables (uppercased name -> value)
;   _extra : type=any
;     any valid keyword name is accepted
;   _ref_extra : type=any
;     any valid keyword name is accepted
;-


;= overload methods

;+
; Define output if `HELP` is called with an `MG_NewObject`. For example::
;
;   IDL> o = mg_newobject(name='Mike') 
;   IDL> help, o
;   O               MG_NEWOBJECT  <ID=4 INSTANCE VARIABLES=1>
;
; :Returns:
;   string
;
; :Params:
;   varname : in, required, type=string
;     variable name
;-
function mg_newobject::_overloadHelp, varname
  compile_opt strictarr

  classname = obj_class(self)
  id = obj_valid(self, /get_heap_identifier)
  format = string(strlen(varname) gt 15 ? '%s' : '%-15s', $
                  format='(%"(%%\"%s %%s  <ID=%%d INSTANCE VARIABLES=%%d>\")")')
  return, string(varname, classname, id, self.instance_variables->count(), $
                 format=format)
end


;+
; Define output if `MG_NewObject` is printed. For example::
;
;   IDL> o = mg_newobject(name='Mike', city='Boulder', age=44)
;   IDL> print, o
;   NAME: Mike
;   CITY: Boulder
;   AGE:       44
;
; :Returns:
;   string
;-
function mg_newobject::_overloadPrint
  compile_opt strictarr

  print_string = string(self.instance_variables, /print)
  return, mg_strmerge(print_string)
end


;= property access

;+
; Set properties.
;-
pro mg_newobject::setProperty, _extra=e
  compile_opt strictarr

  if (n_elements(e) eq 0L) then return
  tag_names = tag_names(e)
  n_tags = n_tags(e)
  for t = 0L, n_tags - 1L do begin
    (self.instance_variables)[tag_names[t]] = e.(t)
  endfor
end


;+
; Get properties.
;-
pro mg_newobject::getProperty, _ref_extra=e
  compile_opt strictarr

  for i = 0L, n_elements(e) - 1L do begin
    (scope_varfetch(e[i], /ref_extra)) = (self.instance_variables)[e[i]]
  endfor
end


;= lifecycle methods

;+
; Free resources.
;-
pro mg_newobject::cleanup
  compile_opt strictarr

  obj_destroy, self.instance_variables
end


;+
; Create an `MG_NewObject`.
;
; :Returns:
;   1 if successful initialization, 0 otherwise
;-
function mg_newobject::init, _extra=e
  compile_opt strictarr

  self.instance_variables = hash()
  self->setProperty, _extra=e

  return, 1
end


;+
; Define `MG_NewObject`.
;-
pro mg_newobject__define
  compile_opt strictarr

  !null = { MG_NewObject, inherits IDL_Object, $
            instance_variables: obj_new() $
          }
end


; main-level example

o = mg_newobject(name='Mike')
o.city = 'Boulder'
o.age = 44
print, o
help, o
print, o.name

end
