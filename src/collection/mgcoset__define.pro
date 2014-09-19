; docformat = 'rst'

;+
; Collection object representing a set.
;
; :Requires:
;    IDL 8.0
;-


;= operator overloading methods

;+
; Handle iterating over the elements in a set.
;
; :Returns:
;   1 if there is a current element to retrieve, 0 if not
;
; :Params:
;   value : in, required, type=scalar numeric
;     return value for the iteration
;   key : in, required, type=undefined or long
;     undefined on initial item and row index for subsequent calls
;-
function mgcoset::_overloadForeach, value, key
  compile_opt strictarr

  status = (self.hash)->_overloadForeach(value, key)
  if (n_elements(key) gt 0L) then value = key

  return, status
end


;+
; Returns the number of elements in the set
;
; :Returns:
;   number of elements in the set
;-
function mgcoset::_overloadSize
  compile_opt strictarr

  return, n_elements(self.hash)
end


;+
; Performance set difference.
;
; :Returns:
;   `MGcoSet` object
;
; :Params:
;   left : in, required, type=set or other iterable
;     left-side operand
;   right : in, required, type=set or other iterable
;     right-side operand
;-
function mgcoset::_overloadMinus, left, right
  compile_opt strictarr

  s = mg_set()

  foreach el, left do s->add, el
  foreach el, right do if (s[el]) then s->remove, el

  return, s
end


;+
; Performance set union.
;
; :Returns:
;   `MGcoSet` object
;
; :Params:
;   left : in, required, type=set or other iterable
;     left-side operand
;   right : in, required, type=set or other iterable
;     right-side operand
;-
function mgcoset::_overloadPlus, left, right
  compile_opt strictarr

  s = mg_set()

  foreach el, left do s->add, el
  foreach el, right do s->add, el

  return, s
end


;+
; Performance set union.
;
; :Returns:
;   `MGcoSet` object
;
; :Params:
;   left : in, required, type=set or other iterable
;     left-side operand
;   right : in, required, type=set or other iterable
;     right-side operand
;-
function mgcoset::_overloadOr, left, right
  compile_opt strictarr

  return, self->_overloadPlus(left, right)
end


;+
; Performance set union.
;
; :Returns:
;   `MGcoSet` object
;
; :Params:
;   left : in, required, type=set or other iterable
;     left-side operand
;   right : in, required, type=set or other iterable
;     right-side operand
;-
function mgcoset::_overloadAnd, left, right
  compile_opt strictarr

  s = mg_set()

  nleft = n_elements(left)
  nright = n_elements(right)

  if (nleft gt nright) then begin
    first = right
    second = left
  endif else begin
    first = left
    second = right
  endelse

  foreach el, first do if (second[el]) then s->add, el

  return, s
end


;+
; Allows array index access with brackets.
;
; :Returns:
;   elements of the same type as the set
;
; :Params:
;   isRange : in, required, type=lonarr(8)
;     indicates whether the i-th parameter is a index range or a scalar/array
;     of indices
;   ss1 : in, required, type=long/lonarr
;     scalar subscript index value, an index array, or a subscript range
;-
function mgcoset::_overloadBracketsRightSide, isRange, ss1
  compile_opt strictarr
  on_error, 2

  if (isRange[0]) then message, 'range not allowed'

  return, (self.hash)->hasKey(ss1)
end


;+
; Evaluates set for truth. True if set contains any values, false otherwise.
;
; :Returns:
;   byte
;-
function mgcoset::_overloadIsTrue
  compile_opt strictarr

  return, self.hash->_overloadIsTrue()
end


;+
; Returns the elements to print. Called by `PRINT` to determine what should be
; displayed.
;
; :Returns:
;   array of elements of the type of the array list
;-
function mgcoset::_overloadPrint
  compile_opt strictarr

  return, ((self.hash)->keys())->_overloadPrint()
end


;+
; Returns a string describing the set. Called by the `HELP` routine.
;
; :Returns:
;   string
;
; :Params:
;   varname : in, required, type=string
;     name of the variable to use when outputting help information
;-
function mgcoset::_overloadHelp, varname
  compile_opt strictarr

  return, string(varname, $
                 'SET', $
                 obj_valid(self, /get_heap_identifier), $
                 n_elements(self.hash), $
                 format='(%"%-15s %-5s <ID=%d  NELEMENTS=%d>")')
end


;= helper methods

;+
; Determine if a set contains a given element.
;
; :Returns:
;   byte
;
; :Params:
;   el : in, required, type=any
;     element to determine if the set contains
;-
function mgcoset::contains, el
  compile_opt strictarr

  return, self.hash->hasKey(el)
end


;+
; Remove elements from the set.
;
; :Params:
;   elements : in, optional, type=any
;     elements to remove
;
; :Keywords:
;   all : in, optional, type=boolean
;     set to remove all elements from the set
;-
pro mgcoset::remove, elements, all=all
  compile_opt strictarr

  (self.hash)->remove, elements, all=all
end


;+
; Add elements to the set.
;
; :Params:
;   elements : in, optional, type=any
;     elements to add to the set
;-
pro mgcoset::add, elements
  compile_opt strictarr

  if (n_elements(elements) eq 0L) then return
  foreach el, elements do (self.hash)[el] = 1B
end


;= lifecycle methods

;+
; Free resources.
;-
pro mgcoset::cleanup
  compile_opt strictarr

  obj_destroy, self.hash
end


;+
; Create set object.
;
; :Returns:
;   1 if successful, 0 otherwise
;
; :Params:
;   elements : in, optional, type=any
;     elements to initialize set with
;-
function mgcoset::init, elements
  compile_opt strictarr

  self.hash = hash()
  self->add, elements

  return, 1
end


;+
; Define instance variables.
;-
pro mgcoset__define
  compile_opt strictarr

  define = { MGcoSet, inherits IDL_Object, hash: obj_new() }
end
