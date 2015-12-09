; docformat = 'rst'

pro mg_widgets2dot_gen, wid, output=output
  compile_opt strictarr

  name = widget_info(wid, /name)
  uname = widget_info(wid, /uname)
  label = '"' + uname + (strlen(uname) gt 0L ? ' ' : '') + '[' + name +']"'

  output->add, string(wid, label, format='(%"%d[shape=box, label=%s]")')

  n_children = widget_info(wid, /n_children)
  all_children = widget_info(wid, /all_children)
  for c = 0L, n_children - 1L do begin
    output->add, string(wid, all_children[c], format='(%"%d -> %d")')
    mg_widgets2dot_gen, all_children[c], output=output
  endfor
end


pro mg_widgets2dot, wid, filename=filename
  compile_opt strictarr

  output = list()
  name = 'widget'
  output->add, string(name, format='(%"digraph hierarchy_of_%s {")')
  output->add, 'node [fontname=Courier]'
  
  mg_widgets2dot_gen, wid, output=output
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
