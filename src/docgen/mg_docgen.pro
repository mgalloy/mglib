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

  _root = file_expand_path(file_dirname(root))
  configuration_filename = filepath('docgen.ini', root=_root)
  config = mg_read_config(configuration_filename)

  files = config->options(section='IDL')
  foreach f, files do begin
    output_filename = config->get(f, section='IDL')
    t = obj_new('MGffTemplate', f)
    t->process, { config: config }, output_filename
    obj_destroy, t
  endforeach

  obj_destroy, config
end