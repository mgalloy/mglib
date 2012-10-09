; docformat = 'rst'

;+
; Abstract class to define a list interface. This class is not intended to be
; instantiated, just to be inherited from.
;-


;+
; Get properties.
;
; :Keywords:
;    version : out, optional, type=long
;       a counter that is incremented as the list is modified (so iterators
;       know if the underlying list has changed)
;-
pro mgcoabstractlist::getProperty, version=version
  compile_opt strictarr

  if (arg_present(version)) then version = self.version
end


;+
; Add elements to the list.
;
; :Abstract:
;
; :Params:
;    elements : in, required, type=list type
;       scalar or vector array of the same type as the list
;
; :Keywords:
;    position : in, optional, type=integer, default=end of list
;       index to insert elements at (NOT IMPLEMENTED)
;-
pro mgcoabstractlist::add, elements, position=position
  compile_opt strictarr

end


;+
; Returns the number of elements in the list.
;
; :Abstract:
; :Returns:
;    long integer
;-
function mgcoabstractlist::count
  compile_opt strictarr

  return, 0L
end


;+
; Get elements of the list.
;
; :Abstract:
;
; :Returns:
;    element(s) of the list or -1L if no elements to return
;
; :Keywords:
;    all : in, optional, type=boolean
;       set to return all elements
;    position : in, optional, type=integer
;       set to an index or an index array of elements to return; defaults to 0
;       if ALL keyword not set
;    count : out, optional, type=integer
;       set to a named variable to get the number of elements returned by this
;       function
;    isa : in, optional, type=string or strarr
;       classname(s) of objects to return; only allowable if list type is
;       object
;-
function mgcoabstractlist::get, all=all, position=position, count=count, isa=isa
  compile_opt strictarr

  return, -1L
end


;+
; Determines whether a list contains specified elements.
;
; :Abstract:
;
; :Returns:
;    1B if contained or 0B if otherwise
;
; :Params:
;    elements : in, required, type=type of list
;       scalar or vector of elements of the same type as the list
;
; :Keywords:
;    position : out, optional, type=long
;       set to a named variable that will return the position of the first
;       instance of the corresponding element of the specified elements
;-
function mgcoabstractlist::isContained, elements, position=position
  compile_opt strictarr

end


;+
; Move an element of the list to another position.
;
; :Abstract:
;
; :Params:
;    source : in, required, type=long
;       index of the element to move
;    destination : in, required, type=long
;       index of position to move element
;-
pro mgcoabstractlist::move, source, destination
  compile_opt strictarr

end


;+
; Remove specified elements from the list.
;
; :Abstract:
;
; :Params:
;    elements : in, optional, type=type of list
;       elements of the list to remove
;
; :Keywords:
;    position : in, optional, type=long
;       set to a scalar or vector array of indices to remove from the list
;    all : in, optional, type=boolean
;       set to remove all elements of the list
;-
pro mgcoabstractlist::remove, elements, position=position, all=all
  compile_opt strictarr

end


;+
; Creates an iterator to iterate through the elements of the list. The
; destruction of the iterator is the responsibility of the caller of this
; method.
;
; :Abstract:
;
; :Returns:
;    MGAbstractIterator object
;-
function mgcoabstractlist::iterator
  compile_opt strictarr

  return, obj_new()
end


;+
; Free resouces.
;-
pro mgcoabstractlist::cleanup
  compile_opt strictarr

  self->IDL_Object::cleanup
end


;+
; Initialize list.
;
; :Returns:
;    1B
;-
function mgcoabstractlist::init
  compile_opt strictarr

  return, 1B
end


;+
; Define member variables.
;
; :Fields:
;    version
;       a counter that is incremented as the list is modified (so iterators
;       know if the underlying list has changed)
;-
pro mgcoabstractlist__define
    compile_opt strictarr

    define = { MGcoAbstractList, inherits IDL_Object, version: 0L }
end
