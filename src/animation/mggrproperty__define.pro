;+
; Apply a property change to the given target.
; 
; @param target {in}{required}{type=object} any object with a setProperty method
;-
pro mggrproperty::apply, target
  compile_opt strictarr

  result = execute('target->setProperty, ' + self.name + '=*self.value')
end


;+
; Free resources.
;-
pro mggrproperty::cleanup
  compile_opt strictarr

  ptr_free, self.value
end


;+
; Initialize object.
;
; @returns 1 for success, 0 otherwise
; @param name {in}{required}{type=string} name of the property
; @param value {in}{required}{type=any} value of the property
;-
function mggrproperty::init, name, value
  compile_opt strictarr

  self.name = name
  self.value = ptr_new(value)

  return, 1
end


;+
; Define member variables.
; 
; @file_comments This class represents a property name/value.
; @field name name of the property
; @field value value of the property
;-
pro mggrproperty__define
  compile_opt strictarr

  define = { MGgrProperty, $
             name : '', $
             value : ptr_new() $
             }
end
