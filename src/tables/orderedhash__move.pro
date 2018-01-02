; docformat = 'rst'

;+
; Hack to add a `move` method to ordered hashes. Move index `src` item to index
; `dst`.
;
; :Params:
;   src : in, required, type=integer
;     source index
;   dst : in, required, type=integer
;     destination index
;-
pro orderedhash::move, src, dst
  compile_opt strictarr

  self.data_list->move, src, dst
end


; main-level example program

o = orderedhash()
o['a'] = 0
o['b'] = 1
o['c'] = 2
o['d'] = 3
print, o
o->move, 3, 1
print, o

end
