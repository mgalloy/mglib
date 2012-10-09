; docformat = 'rst'

;+
; This class represents an array where each element is another array (of
; differing sizes).
;-

;+
; Add an array to the ragged array.
;
; :Params:
;    array : in, required, type=array
;       array to add
;-
pro mgcoraggedarray::add, array
  compile_opt strictarr

end


;+
; Get elements of the array.
;
; :Returns:
;    element(s)
;
; :Keywords:
;    all : in, optional, type=boolean
;       set to return all elements
;    position : in, optional, type=long
;       position of element to return
;    count : out, optional, type=long
;       number of elements returned
;    isa : in, optional, type=string
;       classname to test elements for
;    reverse_indices : out, optional, type=lonarr
;       when a named variable is present routine returns HISTOGRAM type output
;       as the return value and REVERSE_INDICES through this keyword
;    connectivity_list : in, optional, type=boolean
;       set to return a connectivity list format of the results; only valid
;       if the type is a numeric type
;-
function mgcoraggedarray::get, all=all, position=position, count=count, $
                               isa=isa, reverse_indices=reverse_indices, $
                               connectivity_list=connectivityList
  compile_opt strictarr

end


;+
; Free resources.
;-
pro mgcoraggedarray::cleanup
  compile_opt strictarr

  ptr_free, self.pExample
  obj_destroy, [self.oData, self.lengths]

  self->MGcoAbstractList::cleanup
end


;+
; Create a ragged array.
;
; :Returns:
;    1B for succes, 0B otherwise
;
; :Keywords:
;    type : in, optional, type=integer
;       type code as in SIZE function to specify the type of elements in the
;       list; TYPE or EXAMPLE keyword must be used
;    example : in, optional, type=any
;       used to specify the type of the list by example; necessary if defining
;       a list of structures
;    block_size : in, optional, type=integer, default=1000L
;       initial size of data array
;-
function mgcoraggedarray::init, type=type, example=example, block_size=blockSize
  compile_opt strictarr
  on_error, 2

  self.oData = obj_new('mgarraylist', type=10L, blockSize=blockSize)
  self.lengths = obj_new('mgarraylist', type=3L, blockSize=blockSize)

  ; set type
  self.type = n_elements(type) eq 0 ? size(example, /type) : type
  if (self.type eq 0) then message, 'List type is undefined'

  ; store example if structure
  if (self.type eq 8) then begin
    if (n_elements(example) eq 0) then begin
      message, 'Structure lists must specify type with EXAMPLE keyword'
    endif
    self.pExample = ptr_new(example)
  endif

  return, 1B
end


;+
; Define instance variables.
;
; :Fields:
;    oData
;       data
;    lengths
;       lengths of the arrays in the ragged array
;    type
;       type code
;    pExample
;       pointer to example
;-
pro mgcoraggedarray__define
  compile_opt strictarr

  define = { MGcoRaggedArray, inherits MGcoAbstractList, $
             oData: obj_new(), $
             lengths: obj_new(), $
             type: 0L, $
             pExample: ptr_new() $
           }
end
