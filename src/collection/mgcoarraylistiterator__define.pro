; docformat = 'rst'

;+
; This class provides a nice way to iterate through all the elements of an
; array list.
;-

;+
; Determine if the underlying collection has another element to retrieve.
;
; :Returns:
;    1 if underlying collection has another element, 0 otherwise
;-
function mgcoarraylistiterator::hasNext
  compile_opt strictarr

  return, self.pos lt self.arraylist->count()
end


;+
; Return the next item in the underlying collection.
;
; :Returns:
;    list item
;-
function mgcoarraylistiterator::next
  compile_opt strictarr
  on_error, 2

  if (self.pos ge self.arraylist->count()) then begin
    message, 'No more elements'
  endif

  self.arraylist->getProperty, version=version
  if (self.version ne version) then begin
    message, 'Underlying collection has changed'
  endif


  return, self.arraylist->get(position=self.pos++)
end


;+
; Removes from the underlying MGArrayList the last element returned.
;-
pro mgcoarraylistiterator::remove
  compile_opt strictarr
  on_error, 2

  self.arraylist->getProperty, version=version
  if (self.version ne version) then begin
    message, 'Underlying collection has changed'
  endif

  if (self.pos le 0) then begin
    message, 'No element to remove'
  endif

  self.arraylist->remove, position=--self.pos
  self.arraylist->getProperty, version=version
  self.version = version
end


;+
; Free resources of the iterator (not the underlying collection).
;-
pro mgcoarraylistiterator::cleanup
  compile_opt strictarr

  self->MGcoAbstractIterator::cleanup
end


;+
; Initialize an MGArrayListIterator.
;
; :Returns:
;    1 for success, 0 otherwise
;
; :Params:
;    arraylist : in, required, type=object
;       MGcoArrayList to iterator over
;-
function mgcoarraylistiterator::init, arraylist
  compile_opt strictarr

  if (~self->mgcoabstractiterator::init()) then return, 0

  self.arraylist = arraylist
  self.arraylist->getProperty, version=version
  self.version = version

  self.pos = 0

  return, 1B
end


;+
; Define member variables.
;
; :Requires:
;    IDL 6.0
;
; :Fields:
;    arraylist
;       arraylist being interated over
;    pos
;       position of the next element in the ArrayList to be returned by the
;       "next" method
;-
pro mgcoarraylistiterator__define
  compile_opt strictarr

  define = { MGcoArrayListiterator, inherits MGcoAbstractIterator, $
             arraylist: obj_new(), $
             pos: 0L $
           }
end
