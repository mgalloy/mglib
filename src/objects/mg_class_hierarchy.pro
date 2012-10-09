; docformat = 'rst'

;+
; Retrieves or prints a class hierarchy for an object or classname.
;
; :Examples:
;    For example, a list object can be inspected like::
;
;       IDL> lst = list()
;       IDL> mg_class_hierarchy, lst
;       LIST
;         IDL_CONTAINER
;         COLLECTION
;           IDL_OBJECT
;-


;+
; Helper function to cleanup the class hierarchy hash.
;
; :Private:
;
; :Params:
;    hierarchy : in, required, type=hash
;       nested hash with keys of superclass names and values of hierarchy
;       for that superclass
;-
pro mg_class_hierarchy_cleanup, hierarchy
  compile_opt strictarr

  foreach h, hierarchy, classname do begin
    mg_class_hierarchy_cleanup, h
  endforeach

  obj_destroy, hierarchy
end


;+
; Helper function to print the class hierarchy hash.
;
; :Private:
;
; :Params:
;    hierarchy : in, required, type=hash
;       nested hash with keys of superclass names and values of hierarchy
;       for that superclass
;-
pro mg_class_hierarchy_print, hierarchy, indent=indent
  compile_opt strictarr

  _indent = n_elements(indent) eq 0L ? '' : indent

  foreach h, hierarchy, classname do begin
    print, _indent, classname, format='(%"%s%s")'
    mg_class_hierarchy_print, h, indent=_indent + '  '
  endforeach
end


;+
; Helper function to recurse into the superclasses.
;
; :Private:
;
; :Returns:
;    hash
;
; :Params:
;    object : in, required, type=objref or string
;       object or string classname to find superclasses for
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
;    object : in, required, type=objref or string
;       object or string classname to find superclasses for
;
; :Keywords:
;    hierarchy : out, optional, type=hash
;       nested hash with keys of superclass names and values of hierarchy
;       for that superclass
;    no_print : in, optional, type=boolean
;       set to not print the hierarchy
;-
pro mg_class_hierarchy, object, hierarchy=hierarchy, no_print=no_print
  compile_opt strictarr

  hierarchy = hash()
  classname = size(object, /type) eq 11 ? obj_class(object) : strupcase(object)
  hierarchy[classname] = mg_class_hierarchy_helper(object)

  if (~keyword_set(no_print)) then mg_class_hierarchy_print, hierarchy
  if (~arg_present(hierarchy)) then mg_class_hierarchy_cleanup, hierarchy
end


; main-level example

lst = list()
mg_class_hierarchy, lst

end
