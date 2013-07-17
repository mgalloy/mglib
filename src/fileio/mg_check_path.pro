; docformat = 'rst'

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