; docformat = 'rst'

;+
; `MG_DirWalk` is an object that can be used with `FOREACH` to walk through a
; directory hierarchy.
;
; :Example:
;   For example, to traverse the source directories of this library, do the
;   following::
;
;     root = filepath('', subdir=['..'], root=mg_src_root())
;     foreach dir, mg_dirwalk(root, /topdown) do begin
;       print, dir
;     endforeach
;
; :Properties:
;   topdown : type=boolean
;     set to return a directory before its subdirectories; without `TOPDOWN` set
;     the directory will be visited after its subdirectories
;-

;+
; :Private:
;-
function mg_dirwalkiterator::done, only_self_left=only_self_left
  compile_opt strictarr

  ;if (~self.done_self) then return, 0B
  only_self_left = 0B

  if (n_elements(*self.current_subiterators) eq 0L) then begin
    dirs = file_search(filepath('*', root=self.top), /test_directory, count=n_dirs)
    if (n_dirs gt 0L) then begin
      *self.current_subiterators = objarr(n_dirs)
      for d = 0L, n_dirs - 1L do begin
       (*self.current_subiterators)[d] = obj_new('MG_DirWalkIterator', $
                                                 dirs[d], $
                                                 topdown=self.topdown)
      endfor
      self.current_subiterator_index = 0L
      return, 0B
    endif else begin
      only_self_left = ~self.done_self
      return, self.done_self
    endelse
  endif else begin
    n = n_elements(*self.current_subiterators)
    if (self.current_subiterator_index lt n) then begin
      if (self.current_subiterator_index eq n - 1L) then begin
        current = (*self.current_subiterators)[self.current_subiterator_index]
        done = current->done()
        if (done) then begin
          only_self_left = ~self.done_self
          return, self.done_self
        endif else begin
          return, 0B
        endelse
      endif else return, 0B
    endif else begin
      only_self_left = ~self.done_self
      return, self.done_self
    endelse
  endelse
end


;+
; :Private:
;-
function mg_dirwalkiterator::next
  compile_opt strictarr

  if (self->done(only_self_left=only_self_left)) then return, !null

  if ((self.topdown && ~self.done_self) || only_self_left) then begin
    self.done_self = 1B
    return, self.top
  endif

  current = (*self.current_subiterators)[self.current_subiterator_index]
  if (~current->done()) then begin
    return, current->next()
  endif

  self.current_subiterator_index += 1

  return, self->next()
end


;+
; :Private:
;-
pro mg_dirwalkiterator::setProperty, topdown=topdown
  compile_opt strictarr

  if (n_elements(topdown) gt 0L) then self.topdown = topdown
end


;+
; :Private:
;-
pro mg_dirwalkiterator::cleanup
  compile_opt strictarr

  if (n_elements(*self.current_subiterators) gt 0L) then begin
    obj_destroy, *self.current_subiterators
  endif
  ptr_free, self.current_subiterators
end


;+
; :Private:
;-
function mg_dirwalkiterator::init, top, topdown=topdown
  compile_opt strictarr

  self.top = file_expand_path(top)
  self.current_subiterators = ptr_new(/allocate_heap)

  self->setProperty, topdown=topdown

  return, 1
end


;+
; :Private:
;-
pro mg_dirwalkiterator__define
  compile_opt strictarr

  !null = { MG_DirWalkIterator, $
            top: '', $
            done_self: 0B, $
            topdown: 0B, $
            current_subiterators: ptr_new(), $
            current_subiterator_index: 0L $
          }
end


;= overloaded operators

;+
; Handle using `FOREACH` on the dirwalk.
;
; :Params:
;   value : out, optional, type=structure
;     structure of the type::
;
;       { dirpath: '', dirnames: strarr, filenames: strarr }
;
;     if `dirnames` and `filenames` have no elements they will be `!null`
;   iterator : in, out, optional, type=MG_DirWalkIterator
;     object of class MG_DirWalkIterator
;-
function mg_dirwalk::_overloadForeach, value, iterator
  compile_opt strictarr

  if (n_elements(iterator) eq 0L) then begin
    iterator = obj_new('MG_DirWalkIterator', $
                       self.top, $
                       topdown=self.topdown)
  endif

  if (iterator->done()) then begin
    obj_destroy, iterator
    return, 0
  endif

  value = iterator->next()
  return, 1
end


;= property access

;+
; Set properties.
;-
pro mg_dirwalk::setProperty, topdown=topdown
  compile_opt strictarr

  if (n_elements(topdown) gt 0L) then self.topdown = topdown
end


;= lifecycle methods

;+
; Create a dirwalk instance.
;
; :Params:
;   top : in, required, type=string
;     top-level directory to traverse
;-
function mg_dirwalk::init, top, topdown=topdown
  compile_opt strictarr

  self.top = file_expand_path(top)
  self->setProperty, topdown=topdown

  return, 1
end


;+
; Define the `MG_DirWalk` class.
;-
pro mg_dirwalk__define
  compile_opt strictarr

  !null = { MG_DirWalk, inherits IDL_Object, $
            top: '', $
            topdown: 0B $
          }
end


; main-level example program

root = filepath('', subdir=['..'], root=mg_src_root())
foreach dir, mg_dirwalk(root, /topdown) do begin
  print, dir
endforeach

end
