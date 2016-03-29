; docformat = 'rst'

;+
; Retrieves or prints a class hierarchy for an object or classname.
;
; :Examples:
;   For example, a list object can be inspected like::
;
;     IDL> lst = list()
;     IDL> mg_class_hierarchy, lst
;     LIST
;       IDL_CONTAINER
;       COLLECTION
;         IDL_OBJECT
;-


;+
; Helper function to cleanup the class hierarchy hash.
;
; :Private:
;
; :Params:
;   hierarchy : in, required, type=hash
;     nested hash with keys of superclass names and values of hierarchy
;     for that superclass
;-
pro mg_class_hierarchy_cleanup, hierarchy
  compile_opt strictarr

  foreach h, hierarchy, classname do begin
    mg_class_hierarchy_cleanup, h
  endforeach

  obj_destroy, hierarchy
end


;+
; Print the methods of a class in basic syntax, i.e., without arguments.
;
; :Params:
;   classname : in, required, type=string
;     name of the class to check for method of
;
; :Keywords:
;   indent : in, optional, type=string, default=''
;     prefix to indent output by
;-
pro mg_class_hierarchy_print_methods, classname, indent=indent
  compile_opt strictarr

;   man, classname + '::*', output=output
;   ind = where(~output.startsWith('Filename') and output ne '', n_good)
;   good = output[ind]
;   dashes = strarr(n_good) + '  '
;   d_ind = where(~good.startsWith(' '))
; ;  stop
;   dashes[d_ind] = '- '
;   if (n_good gt 0L) then print, transpose(indent + '  ' + dashes + good)

  method_indent = '    '
  functions = [routine_info(/functions), routine_info(/functions, /system)]
  procedures = [routine_info(), routine_info(/system)]
  f_ind = where(functions.startsWith(classname + '::'), n_functions)
  p_ind = where(procedures.startsWith(classname + '::'), n_procedures)
  if (n_functions gt 0L) then print, transpose(indent + method_indent + 'result = ' + strlowcase(functions[f_ind]) + '()')
  if (n_procedures gt 0L) then print, transpose(indent + method_indent + strlowcase(procedures[p_ind]))
end


;+
; Helper function to print the class hierarchy hash.
;
; :Private:
;
; :Params:
;   hierarchy : in, required, type=hash
;     nested hash with keys of superclass names and values of hierarchy
;     for that superclass
;
; :Keywords:
;   indent : in, optional, type=string, default=''
;     prefix to indent output by
;   methods : in, optional, type=boolean
;     if set, list methods of each class as well
;-
pro mg_class_hierarchy_print, hierarchy, indent=indent, methods=methods
  compile_opt strictarr

  _indent = n_elements(indent) eq 0L ? '' : indent

  foreach h, hierarchy, classname do begin
    print, _indent, classname, format='(%"%s%s")'
    if (keyword_set(methods)) then begin
      mg_class_hierarchy_print_methods, classname, indent=_indent
    endif
    mg_class_hierarchy_print, h, indent=_indent + '  ', methods=methods
  endforeach
end


;+
; Helper function to recurse into the superclasses.
;
; :Private:
;
; :Returns:
;   hash
;
; :Params:
;   object : in, required, type=objref or string
;     object or string classname to find superclasses for
;-
function mg_class_hierarchy_helper, object
  compile_opt strictarr

  hierarchy = hash()
  superclasses = obj_class(object, count=nsuperclasses, /superclass)

  for c = 0L, nsuperclasses - 1L do begin
    hierarchy[superclasses[c]] = mg_class_hierarchy_helper(superclasses[c])
  endfor

  return, hierarchy
end


;+
; Retrieves or prints a class hierarchy for an object or classname.
;
; :Params:
;   object : in, required, type=objref or string
;     object or string classname to find superclasses for
;
; :Keywords:
;   hierarchy : out, optional, type=hash
;     nested hash with keys of superclass names and values of hierarchy
;     for that superclass
;   no_print : in, optional, type=boolean
;     set to not print the hierarchy
;   methods : in, optional, type=boolean
;     if set, list methods of each class as well
;-
pro mg_class_hierarchy, object, $
                        hierarchy=hierarchy, $
                        no_print=no_print, $
                        methods=methods
  compile_opt strictarr

  hierarchy = hash()
  classname = size(object, /type) eq 11 ? obj_class(object) : strupcase(object)
  resolve_all, class=classname, /quiet, /continue_on_error
  hierarchy[classname] = mg_class_hierarchy_helper(object)

  if (~keyword_set(no_print)) then mg_class_hierarchy_print, hierarchy, methods=methods
  if (~arg_present(hierarchy)) then mg_class_hierarchy_cleanup, hierarchy
end


; main-level example

lst = list()
mg_class_hierarchy, lst

end
