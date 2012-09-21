; docformat = 'rst'

;+
; :Requires:
;    IDL 8.0
;-


;+
; Handle iterating over the elements in a set.
;
; :Returns:
;    1 if there is a current element to retrieve, 0 if not
;
; :Params:
;    value : in, required, type=scalar numeric
;       return value for the iteration
;    key : in, required, type=undefined or long
;       undefined on initial item and row index for subsequent calls
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
;    number of elements in the set
;-
function mgcoset::_overloadSize
  compile_opt strictarr
  
  return, n_elements(self.hash)
end


;+
; Performance set difference.
;
; :Returns:
;    a new set
;
; :Params:
;    left : in, required, type=set or other iterable
;       left-side operand
;    right : in, required, type=set or other iterable
;       right-side operand
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
;    a new set
;
; :Params:
;    left : in, required, type=set or other iterable
;       left-side operand
;    right : in, required, type=set or other iterable
;       right-side operand
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
;    a new set
;
; :Params:
;    left : in, required, type=set or other iterable
;       left-side operand
;    right : in, required, type=set or other iterable
;       right-side operand
;-
function mgcoset::_overloadOr, left, right
  compile_opt strictarr
  
  return, self->_overloadPlus(left, right)
end


;+
; Performance set union.
;
; :Returns:
;    a new set
;
; :Params:
;    left : in, required, type=set or other iterable
;       left-side operand
;    right : in, required, type=set or other iterable
;       right-side operand
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


function mgcoset::_overloadBracketsRightSide, isRange, $
                                              ss1, ss2, ss3, ss4, $
                                              ss5, ss6, ss7, ss8
  compile_opt strictarr
  on_error, 2
  
  if (isRange[0]) then message, 'range not allowed'

  return, (self.hash)->hasKey(ss1)
end


function mgcoset::_overloadIsTrue
  compile_opt strictarr

  return, self.hash->_overloadIsTrue()
end


function mgcoset::_overloadPrint
  compile_opt strictarr
  
  return, ((self.hash)->keys())->_overloadPrint()
end


function mgcoset::_overloadHelp, varname
  compile_opt strictarr
  
  return, string(varname, $
                 'SET', $
                 obj_valid(self, /get_heap_identifier), $
                 n_elements(self.hash), $
                 format='(%"%-15s %-5s <ID=%d  NELEMENTS=%d>")') 
end


function mgcoset::contains, el
  compile_opt strictarr
  
  return, self.hash->hasKey(el)
end


pro mgcoset::remove, elements, all=all
  compile_opt strictarr

  (self.hash)->remove, elements, all=all
end


pro mgcoset::add, elements
  compile_opt strictarr
  
  if (n_elements(elements) eq 0L) then return
  foreach el, elements do (self.hash)[el] = 1B
end


pro mgcoset::cleanup
  compile_opt strictarr
  
  obj_destroy, self.hash
end


function mgcoset::init, elements
  compile_opt strictarr

  self.hash = hash()
  self->add, elements
  
  return, 1
end


pro mgcoset__define
  compile_opt strictarr
  
  define = { MGcoSet, inherits IDL_Object, hash: obj_new() }
end
