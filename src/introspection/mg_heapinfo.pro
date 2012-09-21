; docformat = 'rst'

;+
; Information about the current state of the heap.
;
; :Keywords:
;    n_pointers : out, optional, type=long
;       set to a named variable to receive the number of pointers on the heap
;    n_objects : out, optional, type=long
;       set to a named variable to receive the number of objects on the heap
;-
pro mg_heapinfo, n_pointers=nPointers, n_objects=nObjects
  compile_opt strictarr

  help, /heap, output=output

  if (arg_present(nPointers)) then begin
    nPointers = long(strmid(output[1], strpos(output[1], ':') + 1))
  endif
    
  if (arg_present(nObjects)) then begin
    nObjects = long(strmid(output[2], strpos(output[2], ':') + 1))
  endif
end
