; docformat = 'rst'

;+
; Wrapper for `FILE_WHICH`, but has an `ALL` keyword to find all matches.
;
; :Examples:
;    For example, try:
;
;       IDL> print, mg_file_which('mgcoarraylist__define.pro', /all)
;       /Users/mgalloy/projects/dist_tools/src/collection/mgcoarraylist__define.pro
;       /Users/mgalloy/projects/idllib/src/collection/mgcoarraylist__define.pro
;       /Users/mgalloy/projects/mgunit/src/dist_tools/collection/mgcoarraylist__define.pro
;       /Users/mgalloy/projects/idldoc/src/collection/mgcoarraylist__define.pro
;       /Users/mgalloy/projects/idldoc/src/dist_tools/collection/mgcoarraylist__define.pro
;       /Users/mgalloy/projects/idldoc/src/collection/mgcoarraylist__define.pro
;       /Users/mgalloy/projects/idldoc/src/dist_tools/collection/mgcoarraylist__define.pro
;
; :Returns:
;    strarr
;
; :Params:
;    path : in, optional, type=string
;       path to search, delimited by `path_sep(/search_path)`
;    file : in, required, type=string
;       file to search for, may include wildcards
;
; :Keywords:
;    include_current_dir : in, optional, type=boolean
;       set to include current directory in the search path
;    all : in, optional, type=boolean
;       set to return all matches instead of just the first one
;-
function mg_file_which, path, file, include_current_dir=includeCurrentDir, $
                        all=all
  compile_opt strictarr

  if (~keyword_set(all)) then begin
    case n_params() of
      1: return, file_which(path, include_current_dir=includeCurrentDir)
      2: return, file_which(path, file, include_current_dir=includeCurrentDir)
    endcase
  endif

  case n_params() of
    1: begin
      _path = !path
      _file = path
    end
    2: begin
      _path = path
      _file = file
    end
  endcase

  if (keyword_set(includeCurrentDir)) then begin
    _path = '.' + path_sep(/search_path) + _path
  endif

  files = file_search(strsplit(_path, path_sep(/search_path), /extract), _file)

  ; for some reason, some results are returned multiple times from FILE_SEARCH
  return, files[uniq(files)]
end
