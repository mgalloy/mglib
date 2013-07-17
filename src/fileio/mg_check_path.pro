; docformat = 'rst'

;+
; Check a file path to see if it exists. If not, then can determine which
; portion of the path is incorrect.
;
; :Returns:
;   1 if filepath exists, 0 if not
;
; :Params:
;   string filepath
;
; :Keywords:
;   partial_path : out, optional, type=string
;     set to a named variable to return the portion of the path which first is
;     is incorrect
;-
function mg_check_path, path, partial_path=partial_path
  compile_opt strictarr

  result = file_test(path)
  if (~result) then begin
    tokens = strsplit(path, path_sep(), /extract, count=ntokens, /preserve_null)
    for t = 1L, ntokens - 1L do begin
      partial_path = strjoin(tokens[0:t], path_sep())
      if (~file_test(partial_path)) then break
    endfor
  endif

  return, result
end