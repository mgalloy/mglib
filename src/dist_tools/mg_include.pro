; docformat = 'rst'

;+
; Includes the contents of the given batch file at the calling level. The 
; call::
; 
;    IDL> mg_include, 'test'
;
; is equivalent to::
;
;    IDL> @test
;
; except that the filename is specified as a string variable instead of
; required to be known at compilation time.
;
; :Params:
;    _mg_include_filename : in, required, type=string
;       filename to include 
;-
pro mg_include, _mg_include_filename
  compile_opt strictarr
  on_error, 2
  
  _mg_include_nlines = file_lines(_mg_include_filename + '.pro')
  _mg_include_lines = strarr(_mg_include_nlines)
  openr, _mg_include_lun, _mg_include_filename + '.pro', /get_lun
  readf, _mg_include_lun, _mg_include_lines
  free_lun, _mg_include_lun
  
  for _mg_include_i = 0L, _mg_include_nlines - 1L do begin
    _mg_include_result = execute(_mg_include_lines[_mg_include_i])
  endfor

  _mg_include_names = scope_varname(count=_mg_include_count)
  
  for _mg_include_i = 0L, _mg_include_count - 1L do begin
    if (strmid(_mg_include_names[_mg_include_i], 0, 12) ne '_MG_INCLUDE_') then begin
      (scope_varfetch(_mg_include_names[_mg_include_i], level=-1, /enter)) $
        = scope_varfetch(_mg_include_names[_mg_include_i])
    endif
  endfor
end
