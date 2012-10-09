; docformat = 'rst'

;+
; Prints the IDL's current directory to the output log like the UNIX command
; of the same name.
;
; :Examples:
;    For example, try::
;
;       IDL> pwd
;       /Users/mgalloy/projects/cmdline_tools
;-
pro pwd
  compile_opt strictarr, hidden

  cd, current=currentDir
  print, currentDir
end
