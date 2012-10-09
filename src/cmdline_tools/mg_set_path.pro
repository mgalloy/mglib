; docformat = 'rst'

;+
; Set the IDL path (`!path`) or DLM path (`!dlm_path`) given an array of
; directories.
;
; :Params:
;    dirs : in, required, type=strarr
;       string array of directories in the path in the correct order; `+`,
;       `<IDL_DEFAULT>`, and other abbreviations used by `EXPAND_PATH` are
;       legal; array elements of `dirs` that begin with ";" are ignored
;
; :Keywords:
;    dlm : in, optional, type=boolean
;       set to set `IDL_DLM_PATH` instead of `IDL_PATH`
;-
pro mg_set_path, dirs, dlm=dlm
  compile_opt strictarr, hidden

  ind = where(stregex(dirs, '^[^;]') ne -1, count)
  path = count eq 0L ? '' : dirs[ind]

  for i = 0L, count - 1L do begin
    path[i] = expand_path(path[i], dlm=dlm)
  endfor

  case 1 of
    keyword_set(dlm): pref = 'IDL_DLM_PATH'
    else: pref = 'IDL_PATH'
  endcase

  pref_set, pref, strjoin(path, path_sep(/search_path)), /commit
end
