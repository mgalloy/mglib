; docformat = 'rst'

;+
; Class representing a routine.
;
; :Private:
;
; :Properties:
;   name
;     name of routine
;   prefix
;     prefix to add to routine
;   prototype
;     prototype line for the routine, if available
;   n_min_parameters
;     minimum number of parameters for routine
;   n_max_parameters
;     maximum number of parameters for routine
;-


;+
; Set properties.
;-
pro mg_routine::setProperty, name=name, $
                             prefix=prefix, $
                             cprefix=cprefix, $
                             is_function=isFunction, $
                             has_keywords=hasKeywords, $
                             prototype=prototype, $
                             n_min_parameters=n_min_parameters, $
                             n_max_parameters=n_max_parameters
  compile_opt strictarr

  if (n_elements(name) gt 0L) then self.name = name
  if (n_elements(prefix) gt 0L) then self.prefix = prefix
  if (n_elements(cprefix) gt 0L) then self.cprefix = cprefix
  if (n_elements(isFunction) gt 0L) then self.is_function = isFunction
  if (n_elements(hasKeywords) gt 0L) then self.has_keywords = hasKeywords
  if (n_elements(prototype) gt 0L) then self.prototype = prototype
  if (n_elements(n_min_parameters) gt 0) then self.n_min_parameters = n_min_parameters
  if (n_elements(n_max_parameters) gt 0) then self.n_max_parameters = n_max_parameters
end


;+
; Get properties.
;-
pro mg_routine::getProperty, name=name, $
                             prefix=prefix, $
                             cprefix=cprefix, $
                             is_function=isFunction, $
                             has_keywords=hasKeywords, $
                             n_min_parameters=n_min_parameters, $
                             n_max_parameters=n_max_parameters, $
                             prototype=prototype
  compile_opt strictarr

  if (arg_present(name)) then name = self.name
  if (arg_present(prefix)) then prefix = self.prefix
  if (arg_present(cprefix)) then cprefix = self.cprefix
  if (arg_present(isFunction)) then isFunction = self.is_function
  if (arg_present(hasKeywords)) then hasKeywords = self.has_keywords
  if (arg_present(n_min_parameters)) then n_min_parameters = self.n_min_parameters
  if (arg_present(n_max_parameters)) then n_max_parameters = self.n_max_parameters
  if (arg_present(prototype)) then prototype = self.prototype
end


;+
; Create string output for the routine's wrapper code.
;
; :Returns:
;    string
;
; :Keywords:
;    preamble : in, optional, type=string/strarr
;      string/string array of code to be inserted after declarations, but before
;      argument checking
;-
function mg_routine::output, preamble=preamble
  compile_opt strictarr

  return, self.code
end


;+
; Free resources.
;-
pro mg_routine::cleanup
  compile_opt strictarr

end


;+
; Create routine binding.
;
; :Returns:
;    1 for success, 0 for failure
;-
function mg_routine::init, code, _extra=e
  compile_opt strictarr

  self.code = code
  self.prefix = ''
  self.cprefix = 'IDL'

  self->setProperty, _extra=e

  return, 1
end


;+
; Defines instance variables.
;
; :Fields:
;   name
;     name of the routine to call
;   prefix
;     prefix to add to routine
;-
pro mg_routine__define
  compile_opt strictarr

  define = { mg_routine, $
             name: '', $
             prototype: '', $
             prefix: '', $
             cprefix: '', $
             code: '', $
             is_function: 0B, $
             has_keywords: 0B, $
             n_min_parameters: 0L, $
             n_max_parameters: 0L $
           }
end
