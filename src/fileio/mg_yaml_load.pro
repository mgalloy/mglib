; docformat = 'rst'

;+
; Parse a YAML-formatted string and return a combination of lists and hashes.
;
; :Returns:
;   object
;
; :Params:
;   s : in, optional, type=string
;     string to parse, one of `s` or `filename` is required
;
; :Keywords:
;   filename : in, optional, type=string
;     set to specify a filename to read and then parse, instead of parsing `s`,
;     one of `s` or `filename` is required
;-
function mg_yaml_load, s, filename=filename
  compile_opt strictarr

  ; see $HOME/anaconda/lib/python2.7/site-packages/yaml for a YAML grammar
end
