; docformat = 'rst'

;+
; Creates a `.dot` file for GraphViz representing an object class hierarchy.
;-

pro mg_classes2dot_gen, cls, hierarchy, output=output
  compile_opt strictarr

  output->add, string(cls, format='(%"%s[shape=box]")')

  count = hierarchy->count()
  if (count eq 0L) then return

  superclasses = hierarchy->keys()
  cs = ''
  foreach c, superclasses do begin
    output->add, string(c, cls, format='(%"%s -> %s\n")')
    mg_classes2dot_gen, c, hierarchy[c], output=output
    cs += c + ' '
  endforeach
  if (count gt 1L) then output->add, string(cs, format='(%"{ rank=same; %s }")')
  obj_destroy, superclasses
end


pro mg_classes2dot, obj, filename=filename
  compile_opt strictarr

  mg_class_hierarchy, obj, hierarchy=h, /no_print

  keys = h->keys()
  name = keys[0]
  obj_destroy, keys

  output = list()
  output->add, string(name, format='(%"digraph hierarchy_of_%s {")')
  output->add, 'node [fontname=Courier]'
  
  mg_classes2dot_gen, name, h[name], output=output
  output->add, '}'

  result = mg_strmerge(output->toArray())
  obj_destroy, output

  if (n_elements(filename) gt 0L) then begin
    openw, lun, filename, /get_lun
    printf, lun, result
    free_lun, lun
  endif else begin
    print, result
  endelse
end
