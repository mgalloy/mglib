; docformat = 'rst'

;+
; An array list is a way to have an arbitrary length list of any particular
; IDL variable (but all elements must be the same type). An `MGcoArrayList`
; implements the same interface as `IDL_Container`, but can contain any IDL
; type.
;
; :Author:
;   Michael Galloy
;
; :Version:
;   1.1
;
; :Properties:
;   type
;     type code as in `SIZE` function to specify the type of elements in the
;     list; `TYPE` or `EXAMPLE` keyword must be used when initializing the
;     array list
;   block_size
;     initial size of the data array; defaults to 1000 if not specified
;   example
;     type defined by an example instead of a type code (required for array
;     lists of structures)
;   count
;     number of elements in the array list
;   _ref_extra
;     keywords to `MGcoAbstractList::getProperty`
;
; :Examples:
;   For example::
;
;     a = obj_new('MGcoArrayList', type=7)
;
;     a->add, 'a'
;     a->add, ['b', 'c', 'd']
;
;     print, a->count()
;     print, a->get(/all)
;     print, a->get(position=1)
;
;     obj_destroy, a
;-


;= Overloading operator methods

;+
; Allows array index access with brackets.
;
; :Examples:
;   Try::
;
;     IDL> a = obj_new('MGcoArrayList', type=4)
;     IDL> a->add, findgen(10)
;     IDL> print, a[0:5:1]
;
; :Bugs:
;   when using an index array to index an array list, out-of-bounds indices
;   larger than the last element's index are not handled property -- they do
;   not return the last element (negative indices will return the first
;   element, though)
;
; :Returns:
;   elements of the same type as the array list
;
; :Params:
;   isRange : in, required, type=lonarr(8)
;     indicates whether the i-th parameter is a index range or a scalar/array
;     of indices
;   ss1 : in, required, type=long/lonarr
;     scalar subscript index value, an index array, or a subscript range
;   ss2 : in, optional, type=any
;     not used
;   ss3 : in, optional, type=any
;     not used
;   ss4 : in, optional, type=any
;     not used
;   ss5 : in, optional, type=any
;     not used
;   ss6 : in, optional, type=any
;     not used
;   ss7 : in, optional, type=any
;     not used
;   ss8 : in, optional, type=any
;     not used
;-
function mgcoarraylist::_overloadBracketsRightSide, isRange, $
                                                    ss1, ss2, ss3, ss4, $
                                                    ss5, ss6, ss7, ss8
  compile_opt strictarr
  on_error, 2

  if (isRange[0]) then begin
    _ss1 = ss1
    if (_ss1[1] le 0L) then _ss1[1] = (_ss1[1] + self.nUsed) mod self.nUsed
    return, (*self.pData)[_ss1[0]:_ss1[1]:_ss1[2]]
  endif else begin
    ; handle index arrays
    if (n_elements(ss1) gt 1) then return, (*self.pData)[ss1]

    if (ss1 ge self.nUsed) then begin
      message, string(ss1, format='(%"Attempt to subscript with %d is out of range")')
    endif

    index = ss1 mod self.nUsed
    if (index lt 0) then index = (index + self.nUsed) mod self.nUsed

    return, (*self.pData)[index]
  endelse
end


;+
; Allows setting values of the array list by array index.
;
; :Examples:
;   Try::
;
;     IDL> a = obj_new('MGcoArrayList', type=4)
;     IDL> a->add, findgen(10)
;     IDL> a[0:-3:2] = findgen(4)
;     IDL> print, a
;           0.00000      1.00000      1.00000      3.00000      2.00000
;           5.00000      3.00000      7.00000      8.00000      9.00000
;
; :Params:
;   objref : in, required, type=objref
;     should be self
;   value : in, required, type=any
;     value to assign to the array list
;   isRange : in, required, type=lonarr(8)
;     indicates whether the i-th parameter is a index range or a scalar/array
;     of indices
;   ss1 : in, required, type=long/lonarr
;     scalar subscript index value, an index array, or a subscript range
;-
pro mgcoarraylist::_overloadBracketsLeftSide, objref, value, isRange, ss1
  compile_opt strictarr

  if (isRange[0]) then begin
    _ss1 = ss1
    if (_ss1[1] le 0L) then _ss1[1] = (_ss1[1] + self.nUsed) mod self.nUsed
    (*self.pData)[_ss1[0]:_ss1[1]:_ss1[2]] = value
  endif else begin
    if (ss1 + n_elements(value) gt self.nUsed) then begin
      message, 'Out of range subscript encountered'
    endif

    index = ss1 mod self.nUsed
    if (index lt 0) then index = (index + self.nUsed) mod self.nUsed

    (*self.pData)[index] = value
  endelse
end


;+
; Concatenate two array lists.
;
; :Returns:
;   `MGcoArrayList` object
;
; :Params:
;   left : in, required, type=MGcoArrayList
;     an array list to concatenate
;   right : in, required, type=MGcoArrayList
;     an array list to concatenate
;-
function mgcoarraylist::_overloadPlus, left, right
  compile_opt strictarr
  on_error, 2

  left->getProperty, block_size=leftBlockSize, type=leftType, $
                     count=leftCount, example=leftExample
  right->getProperty, block_size=rightBlockSize, type=rightType, $
                      count=rightCount, example=rightExample

  if (leftType ne rightType) then begin
    message, 'cannot concatenate array lists of different types'
  endif

  ; TODO: should check to see that leftExample and rightExample are the same
  ;       if they are defined, but don't know how to compare them

  result = obj_new('MGcoArrayList', $
                   type=leftType, example=leftExample, $
                   block_size=(leftCount > rightCount) > (leftBlockSize > rightBlockSize))
  if (leftCount gt 0L) then result->add, left->get(/all)
  if (rightCount gt 0L) then result->add, right->get(/all)

  return, result
end


;+
; Helper routine to repeat numeric elements.
;
; :Private:
;
; :Returns:
;   array of same type as elements
;
; :Params:
;   elements : in, required, type=real numeric type
;     elements to repeat
;   mult : in, required, type=integer
;     multiplier indicating how many times to repeat elements
;-
function mgcoarraylist::_repeatNumeric, elements, mult
  compile_opt strictarr

  n = n_elements(elements)
  return, reform(rebin(reform(elements, n, 1), n, mult), n * mult)
end


;+
; Helper routine to repeat non-numeric elements (more slowly then for
; numeric elements).
;
; :Private:
;
; :Returns:
;   array of same type as elements
;
; :Params:
;   elements : in, required, type=real numeric type
;     elements to repeat
;   mult : in, required, type=integer
;     multiplier indicating how many times to repeat elements
;-
function mgcoarraylist::_repeatNonNumeric, elements, mult
  compile_opt strictarr

  n = n_elements(elements)
  result = make_array(n * mult, type=size(elements, /type))

  for i = 0L, mult - 1L do result[i * n] = elements

  return, result
end


;+
; Helper routine to repeat structure elements (more slowly then for
; numeric elements).
;
; :Private:
;
; :Returns:
;   array of same type as elements
;
; :Params:
;   elements : in, required, type=real numeric type
;     elements to repeat
;   mult : in, required, type=integer
;     multiplier indicating how many times to repeat elements
;-
function mgcoarraylist::_repeatStructure, elements, mult
  compile_opt strictarr

  n = n_elements(elements)
  result = replicate(elements[0], n * mult)

  for i = 0L, mult - 1L do result[i * n] = elements

  return, result
end


;+
; Repeat an array list a given number of times.
;
; :Returns:
;   `MGcoArrayList` object
;
; :Params:
;   left : in, required, type=MGcoArrayList/integer
;     an array list to repeat or a multiplier
;   right : in, required, type=MGcoArrayList/integer
;     an array list to repeat or a multiplier
;-
function mgcoarraylist::_overloadAsterisk, left, right
  compile_opt strictarr
  on_error, 2

  case 1 of
    size(left, /type) ne 11: begin
        mult = left
        lst = right
      end
    size(right, /type) ne 11: begin
        mult = right
        lst = left
      end
    else: message, 'need a non-object multiplier'
  endcase

  if (mult le 0) then message, 'multiplier must be positive'

  lst->getProperty, block_size=blockSize, count=count, type=type, example=example

  elements = lst->get(/all)

  result = obj_new('MGcoArrayList', $
                   type=type, example=example, $
                   block_size=blockSize > (mult * count))

  case type of
    0:
    1: rep = self->_repeatNumeric(elements, mult)
    2: rep = self->_repeatNumeric(elements, mult)
    3: rep = self->_repeatNumeric(elements, mult)
    4: rep = self->_repeatNumeric(elements, mult)
    5: rep = self->_repeatNumeric(elements, mult)
    6: rep = self->_repeatNonNumeric(elements, mult)
    7: rep = self->_repeatNonNumeric(elements, mult)
    8: rep = self->_repeatStructure(elements, mult)
    9: rep = self->_repeatNonNumeric(elements, mult)
    10: rep = self->_repeatNonNumeric(elements, mult)
    11: rep = self->_repeatNonNumeric(elements, mult)
    12: rep = self->_repeatNumeric(elements, mult)
    13: rep = self->_repeatNumeric(elements, mult)
    14: rep = self->_repeatNumeric(elements, mult)
    15: rep = self->_repeatNumeric(elements, mult)
  endcase

  result->add, rep

  return, result
end


;+
; Allows an array list to be used in a `FOREACH` loop.
;
; :Returns:
;   1 if there is an item to return, 0 if not
;
; :Params:
;   value : out, required, type=list type
;     value to return as the loop
;   key : in, out, optional, type=undefined/long
;     key is undefined for first element, otherwise the index of the last
;     element returned
;-
function mgcoarraylist::_overloadForeach, value, key
  compile_opt strictarr

  key = n_elements(key) eq 0L ? 0L : (key + 1L)
  if (key lt self.nUsed) then begin
    value = (*self.pData)[key]
    return, 1
  endif else return, 0
end


;+
; Returns the elements to print. Called by `PRINT` to determine what should be
; displayed.
;
; :Returns:
;   array of elements of the type of the array list
;-
function mgcoarraylist::_overloadPrint
  compile_opt strictarr

  return, self.nUsed eq 0L ? '[]' : (*self.pData)[0:self.nUsed-1L]
end


;+
; Returns a string describing the array list. Called by the `HELP` routine.
;
; :Returns:
;   string
;
; :Params:
;   varname : in, required, type=string
;     name of the variable to use when outputting help information
;-
function mgcoarraylist::_overloadHelp, varname
  compile_opt strictarr

  all_types = ['UNDEFINED', 'BYTE', 'INT', 'LONG', 'FLOAT', 'DOUBLE', $
               'COMPLEX', 'STRING', 'STRUCTURE', 'DCOMPLEX', 'POINTER', $
               'OBJREF', 'UINT', 'ULONG', 'LONG64', 'ULONG64']
  type = all_types[self.type]

  specs = string(self.nUsed, '(%"MGcoArrayList[%d]")')
  return, string(varname, type, specs, format='(%"%-15s %-9s = %s")')
end


;+
; Returns the number of elements in the array list. Called by `SIZE` to
; retrieve information about the size of the variable.
;
; :Returns:
;   long
;-
function mgcoarraylist::_overloadSize
  compile_opt strictarr

  return, self.nUsed
end


;= property access

;+
; Get properties of the list.
;
; :Keywords:
;   type : out, optional, type=long
;     `SIZE` type code for elements in the array list
;   block_size : out, optional, type=long
;     size of a block
;   example : out, optional, type=any
;     example element of the type of the array list
;   count : out, optional, type=long
;     number of elements in the array list
;   _ref_extra : out, optional, type=keywords
;     properties of `MGcoAbstractList`
;-
pro mgcoarraylist::getProperty, type=type, block_size=blockSize, $
                                example=example, count=count, _ref_extra=e
  compile_opt strictarr, logical_predicate

  if (arg_present(type)) then type = self.type
  if (arg_present(blockSize)) then blockSize = self.blockSize
  if (arg_present(example) && ptr_valid(self.pExample)) then begin
    example = *self.pExample
  endif
  if (arg_present(count)) then count = self.nUsed

  if (n_elements(e) gt 0) then begin
    self->mgcoabstractlist::getProperty, _strict_extra=e
  endif
end


;+
; Set properties of the list.
;
; :Keywords:
;   type : in, optional, type=long
;     `SIZE` type code for elements in the array list
;   block_size : in, optional, type=long
;     size of a block
;-
pro mgcoarraylist::setProperty, type=type, block_size=blockSize
  compile_opt strictarr
  on_error, 2

  if (n_elements(type) gt 0 && ((type eq 8) ne (self.type eq 8))) then begin
    message, 'Cannot convert between structures and other types'
  endif

  if (n_elements(blockSize) gt 0 && (blockSize lt self.nUsed)) then begin
    message, 'Cannot set the blockSize to less than number of elements in list'
  endif

  if (n_elements(type) eq 0 && n_elements(blockSize) eq 0) then return

  self.version++

  self.type = n_elements(type) eq 0 ? self.type : type
  self.blockSize = n_elements(blockSize) eq 0 ? self.blockSize : blockSize

  if (self.type eq 8) then begin
    newData = replicate(*self.pExample, self.blockSize)
  endif else begin
    newData = make_array(self.blockSize, type=self.type, /nozero)
  endelse

  newData[0] = (*self.pData)[0:self.nUsed-1L]
  *self.pData = newData
end


;= helper methods

;+
; Remove specified elements from the list.
;
; :Params:
;   elements : in, optional, type=type of list
;     elements of the list to remove
;
; :Keywords:
;   position : in, optional, type=long
;     set to a scalar or vector array of indices to remove from the list
;   all : in, optional, type=boolean
;     set to remove all elements of the list
;-
pro mgcoarraylist::remove, elements, position=position, all=all
  compile_opt strictarr
  ;on_error, 2

  self.version++

  ; nothing to remove
  if (self.nUsed eq 0L) then return

  ; handle ALL keyword
  if (keyword_set(all)) then begin
    self.nUsed = 0L
    return
  endif

  ; handle POSITION keyword
  if (n_elements(position) gt 0L) then begin
    if (n_elements(position) lt self.nUsed) then begin
      keep = bytarr(self.nUsed) + 1B
      keep[position] = 0B
      keep_ind = where(keep)
      (*self.pData)[0L:self.nUsed - n_elements(position) - 1L] = (*self.pData)[keep_ind]
    endif

    self.nUsed -= n_elements(position)
  endif

  ; remove first element in the list
  if (n_elements(position) eq 0L && n_elements(elements) eq 0L) then begin
    if (self.nUsed ne 1) then begin
      (*self.pData)[0L] = (*self.pData)[1L:self.nUsed-1L]
    endif
    self.nUsed--
    return
  endif

  ; remove specified elements in the list
  for i = 0L, n_elements(elements) - 1L do begin
    keepIndices = where((*self.pData)[0L:self.nUsed-1L] ne elements[i], $
                        nKeep)
    if (nKeep gt 0L) then begin
      self.nUsed = nKeep
      (*self.pData)[0L] = (*self.pData)[keepIndices]
    endif else begin
      self.nUsed = 0L
      break
    endelse
  endfor
end


;+
; Move an element of the list to another position.
;
; :Params:
;   source : in, required, type=long
;     index of the element to move
;   destination : in, required, type=long
;     index of position to move element
;-
pro mgcoarraylist::move, source, destination
  compile_opt strictarr, logical_predicate

  self.version++

  ; bounds checking on source and destination
  if (source lt 0 || source ge self.nUsed) then begin
    message, 'Source index out of bounds'
  endif
  if (destination lt 0 || destination ge self.nUsed) then begin
    message, 'Destination index out of bounds'
  endif

  sourceElement = (*self.pData)[source]
  if (source lt destination) then begin
    (*self.pData)[source] =  (*self.pData)[source+1L:destination]
  endif else begin
    (*self.pData)[destination+1L] = (*self.pData)[destination:source-1L]
  endelse
  (*self.pData)[destination] = sourceElement
end


;+
; Determines whether a list contains specified elements.
;
; :Returns:
;   1B if contained or 0B if otherwise
;
; :Params:
;   elements : in, required, type=type of list
;     scalar or vector of elements of the same type as the list
;
; :Keywords:
;   position : out, optional, type=long
;     set to a named variable that will return the position of the first
;     instance of the corresponding element of the specified elements
;-
function mgcoarraylist::isContained, elements, position=position
  compile_opt strictarr, logical_predicate

  n = n_elements(elements)
  position = lonarr(n)

  isContained = n gt 0 ? bytarr(n) : 0B
  for i = 0L, n - 1L do begin
    ind = where(*self.pData eq elements[i], nFound)
    isContained[i] = nFound gt 0L
    position[i] = ind[0]
  endfor

  return, isContained
end


;+
; Add elements to the list.
;
; :Params:
;   elements : in, required, type=list type
;     scalar or vector array of the same type as the list
;
; :Keywords:
;   position : in, optional, type=long/lonarr, default=end of list
;     index or index array to insert elements at; if array, must match
;     number of elements
;-
pro mgcoarraylist::add, elements, position=position
  compile_opt strictarr

  self.version++
  nNew = mg_n_elements(elements, /no_operatoroverload)

  ; double the size of the list until there is enough room
  if (self.nUsed + nNew gt self.blockSize) then begin
    self.blockSize *= 2L
    while (self.nUsed + nNew gt self.blockSize) do self.blockSize *= 2L
    if (self.type eq 8) then begin
      newData = replicate(*self.pExample, self.blockSize)
    endif else begin
      newData = make_array(self.blockSize, type=self.type)
    endelse
    newData[0] = *self.pData
    *self.pData = temporary(newData)
  endif

  ; add the elements
  case n_elements(position) of
    0 : begin
      (*self.pData)[self.nUsed] = elements
      self.nUsed += nNew
    end
    1 : begin
      ; shift down any elements to the right of position
      if (position lt self.nUsed) then begin
        (*self.pData)[position+nNew] = (*self.pData)[position:self.nUsed-1L]
      endif
      (*self.pData)[position] = elements
      self.nUsed += nNew
    end
    else : begin
      for el = 0L, nNew - 1L do begin
        self->add, elements[el], position=position[el]
      endfor
    end
  endcase
end


;+
; Private method to screen for given class(es). Indices returned are indices
; `POSITION` (or data array if `ALL` is set).
;
; :Private:
;
; :Returns:
;   index array or -1L if none
;
; :Keywords:
;   position : in, optional, type=lonarr
;     indices of elements to check
;   isa : in, required, type=string/strarr
;     classes to check objects for
;   count : out, optional, type=long
;     number of matched items
;   all : in, optional, type=boolean
;     screen from all elements
;-
function mgcoarraylist::isaGet, position=position, isa=isa, all=all, $
                                count=count
  compile_opt strictarr

  ; handle the /ALL case separately because I don't want to create a large
  ; index array for POSITION
  if (keyword_set(all)) then begin
    good = bytarr(self.blocksize)
    for i = 0L, n_elements(isa) - 1L do begin
      good or= obj_isa(*self.pData, isa[i])
    endfor
    return, where(good, count)
  endif

  nPos = n_elements(position)
  good = bytarr(nPos)
  for i = 0L, n_elements(isa) - 1L do begin
    good or= obj_isa((*self.pData)[position], isa[i])
  endfor

  return, where(good, count)
end


;+
; Get elements of the list.
;
; :Returns:
;   element(s) of the list or -1L if no elements to return
;
; :Keywords:
;   all : in, optional, type=boolean
;     set to return all elements
;   position : in, optional, type=long/lonarr
;     set to an index or an index array of elements to return; defaults to 0
;     if `ALL` keyword not set
;   count : out, optional, type=integer
;     set to a named variable to get the number of elements returned by this
;     function
;   isa : in, optional, type=string/strarr
;     classname(s) of objects to return; only allowable if list type is
;     object
;-
function mgcoarraylist::get, all=all, position=position, count=count, isa=isa
  compile_opt strictarr
  on_error, 2

  ; return -1L if no elements
  if (self.nUsed eq 0) then begin
    count = 0L
    return, -1L
  endif

  ; return all the elements
  if (keyword_set(all)) then begin
    count = self.nUsed
    if (self.type eq 11 && n_elements(isa) gt 0) then begin
      ind = self->isaGet(all=all, isa=isa, count=count)
      if (count eq 0) then return, -1L
      return, (*self.pData)[ind]
    endif
    return, (*self.pData)[0:self.nUsed-1L]
  endif

  ; return first element if ALL or POSITION are not present
  if (n_elements(position) eq 0) then begin
    count = 1L
    if (self.type eq 11 && n_elements(isa) gt 0) then begin
      ind = self->isaGet(position=0, isa=isa, count=count)
      if (count eq 0) then return, -1L
      return, (*self.pData)[ind]
    endif
    return, (*self.pData)[0]
  endif

  ; make sure POSITION keyword is in valid range
  badInd = where(position lt 0 or position gt (self.nUsed - 1L), nOutOfBounds)
  if (nOutOfBounds gt 0) then begin
    message, 'Position value out of range'
  endif

  ; return elements selected by POSITION keyword
  count = n_elements(position)
  if (self.type eq 11 && n_elements(isa) gt 0) then begin
    ind = self->isaGet(position=position, isa=isa, count=count)
    if (count eq 0) then return, -1L
    return, (*self.pData)[position[ind]]
  endif
  return, (*self.pData)[position]
end


;+
; Returns the number of elements in the list.
;
; :Returns:
;   long
;-
function mgcoarraylist::count
  compile_opt strictarr

  return, self.nUsed
end


;+
; Creates an iterator to iterate through the elements of the array list. The
; destruction of the iterator is the responsibility of the caller of this
; method.
;
; :Returns:
;    MGcoArrayListIterator object
;-
function mgcoarraylist::iterator
  compile_opt strictarr

  return, obj_new('MGcoArrayListIterator', self)
end


;= lifecycle methods

;+
; Cleanup list resources.
;-
pro mgcoarraylist::cleanup
  compile_opt strictarr

  ; if data is objects, free them
  if (self.type eq 11) then obj_destroy, *self.pData

  ptr_free, self.pExample, self.pData

  self->MGcoAbstractList::cleanup
end


;+
; Create a list.
;
; :Returns:
;   1B for succes, 0B otherwise
;
; :Params:
;   elements : in, optional, type=any
;     scalar or array of original value(s) of the array list
;
; :Keywords:
;   type : in, optional, type=long
;     `SIZE` type code for elements in the array list
;   block_size : in, optional, type=long
;     size of a block
;   example : in, optional, type=any
;     example element of the type of the array list
;-
function mgcoarraylist::init, elements, $
                              type=type, example=example, $
                              block_size=blockSize
  compile_opt strictarr
  on_error, 2

  self.nUsed = 0L

  ; set type
  self.type = n_elements(type) eq 0 $
                ? (n_elements(elements) eq 0 $
                     ? size(example, /type) $
                     : size(elements, /type)) $
                : type
  if (self.type eq 0) then message, 'List type is undefined'

  ; set blockSize
  self.blockSize = n_elements(blockSize) eq 0 ? 1000 : blockSize
  if (self.blockSize le 0) then message, 'List size must be positive'
  self.blockSize >= n_elements(value)

  ; create the list elements -- structures are special
  if (self.type eq 8) then begin
    if (n_elements(example) eq 0) then begin
      message, 'Structure lists must specify type with EXAMPLE keyword'
    endif
    data = replicate(example, self.blockSize)
    self.pExample = ptr_new(example)
  endif else begin
    data = make_array(self.blockSize, type=self.type)
  endelse

  self.pData = ptr_new(data, /no_copy)

  if (n_elements(elements) gt 0) then self->add, elements

  return, 1B
end


;+
; Define member variables.
;
; :Categories: object, collection
;
; :Fields:
;   pData
;     pointer to the data array
;   nUsed
;     number of elements of the list actually in use
;   type
;     `SIZE` type code of the data array
;   blockSize
;     size of the data array
;   pExample
;     used if list of structures to specify the structure
;-
pro mgcoarraylist__define
  compile_opt strictarr

  define = { MGcoArrayList, inherits MGcoAbstractList, $
             pData: ptr_new(), $
             nUsed: 0L, $
             type: 0L, $
             blockSize: 0L, $
             pExample: ptr_new() $
           }
end
