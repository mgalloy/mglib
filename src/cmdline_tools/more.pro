; docformat = 'rst'

;+
; Page the contents of the filename to the screen.
;
: :Examples:
;    For example, to print the contents of the `pwd.pro` file to the output
;    log::
;
;       IDL> more, file_which('pwd.pro')
;       ; docformat = 'rst'
;
;       ;+
;       ; Prints the IDL's current directory to the output log.
;       ;-
;       pro pwd
;         compile_opt strictarr, hidden
;
;         cd, current=currentDir
;         print, currentDir
;       end
;
; :Params:
;    filename : in, required, type=string
;       filename to display
;-
pro more, filename
  compile_opt strictarr

  nlines = file_lines(filename)
  output = strarr(1, nlines)
  openr, lun, filename, /get_lun
  readf, lun, output
  free_lun, lun

  terminal = !version.os_family eq 'unix' ? '/dev/tty' : 'CON:'
  openw, outlun, terminal, /get_lun, /more
  printf, outlun, output
  free_lun, outlun
end
