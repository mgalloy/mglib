; docformat = 'rst'

;+
; Writes a configuration file.
;
; :Params:
;   filename : in, required, type=string
;     filename of file to write
;   config: in, required, type=`MGffOptions` object
;     configuration options to write
;-
pro mg_write_config, filename, config
  compile_opt strictarr

  output = config->_overloadPrint()
  openw, lun, filename, /get_lun
  printf, lun, output
  free_lun, lun
end
