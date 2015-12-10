; docformat = 'rst'

pro mg_og2dot_gen, og, output=output
  compile_opt strictarr

  og->getProperty, name=name
  label = '"' + name + (strlen(name) gt 0L ? ' ' : '') + '[' + obj_class(og) +']"'
  
  id = obj_valid(og, /get_heap_identifier)
  output->add, string(id, $
                      label, $
                      format='(%"%d[shape=box, label=%s]")')

  if (obj_isa(og, 'IDL_Container')) then begin
    for c = 0L, og->count() - 1L do begin
      child = og->get(position=c)
      output->add, string(id, obj_valid(child, /get_heap_identifier), $
                          format='(%"%d -> %d")')
      mg_og2dot_gen, child, output=output
    endfor
  endif
end


pro mg_og2dot, og, filename=filename
  compile_opt strictarr

  output = list()
  name = 'object_graphics'
  output->add, string(name, format='(%"digraph hierarchy_of_%s {")')
  output->add, 'node [fontname=Courier]'
  
  mg_og2dot_gen, og, output=output
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
