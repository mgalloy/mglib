; docformat ='rst'

;+
; Print a search path nicely in the output log.
;
; :Examples:
;    For example, try::
;
;       IDL> mg_print_path, !dlm_path
;       /Users/mgalloy/projects/gpulib/IDL
;       /Users/mgalloy/projects/vis/src/flow
;       /Users/mgalloy/projects/vis/src/lineplots
;       /Users/mgalloy/projects/mpidl/install/lib
;       /Users/mgalloy/projects/idllib/src/analysis
;       /Users/mgalloy/projects/idllib/src/cula
;       /Users/mgalloy/projects/idllib/src/gsl
;       /Users/mgalloy/projects/idllib/src/introspection
;       /Users/mgalloy/projects/idllib/src/net
;       /Users/mgalloy/projects/cmdline_tools/src
;       /Users/mgalloy/projects/dist_tools/src
;       /Applications/itt/idl/idl80/bin/bin.darwin.x86_64
;
; :Params:
;    path : in, optional, type=string, default=!path
;       list of directories concatented using the system OS separator 
;       character, as in `!path` or `!dlm_path`
;-
pro mg_print_path, path
  compile_opt strictarr
  
  _path = n_elements(path) eq 0L ? !path : path
  
  print, transpose(strsplit(_path, path_sep(/search_path), /extract))
end