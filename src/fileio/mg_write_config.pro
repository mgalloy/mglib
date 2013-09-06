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

  openw, lun, filename, /get_lun

  ; could do "printf, lun, config", but that wouldn't work pre-IDL 8.0
  output = config->_overloadPrint()
  printf, lun, output

  free_lun, lun
end
