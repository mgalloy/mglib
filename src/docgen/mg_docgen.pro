; docformat = 'rst'

;+
; Generate docs for a given directory.
;
; :Params:
;   root : in, required, type=string
;     directory to look for 'docgen.ini' file
;-
pro mg_docgen, root
  compile_opt strictarr

  t0 = systime(/seconds)

  _root = file_expand_path(file_dirname(root))
  configuration_filename = filepath('docgen.ini', root=_root)
  config = mg_read_config(configuration_filename)

  files = config->options(section='Templates')
  foreach f, files do begin
    output_filename = config->get(f, section='Templates')
    print, f, output_filename, format='(%"Processing %s (%s)...")'
    t = obj_new('MGffTemplate', f)
    t->process, { config: config }, output_filename
    obj_destroy, t
  endforeach

  obj_destroy, config
  t1 = systime(/seconds)

  print, t1 - t0, format='(%"Finished in %0.2f seconds")'
end