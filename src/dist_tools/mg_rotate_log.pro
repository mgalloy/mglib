; docformat = 'rst'

;+
; Rotate logs to allow `basename` to be written from scratch. Copies `basename`
; to `basename.1`, previous `basename.1` to `basename.2`, etc.
;
; :Uses:
;   mg_str_isnumber
;
; :Params:
;   basename : in, required, type=string
;     full path to base log file, i.e., before adding .1, .2, etc.
;
; :Keywords:
;   max_version : in, optional, type=integer
;     if present, delete any logs that would be rotated to a version greater
;     than `max_version`
;-
pro mg_rotate_log, basename, max_version=max_version
  compile_opt strictarr

  ; if basename is not present, it is already OK to write a log of that name
  if (~file_test(basename, /regular)) then return

  ; find all the numbered logs
  logs = file_search(basename + '.*', /test_regular, count=n_logs)

  ; rotate logs
  if (n_logs gt 0L) then begin
    has_max = n_elements(max_version) gt 0L

    len = strlen(basename)
    dots = strmid(logs, len, 1)
    versions = strmid(logs, len + 1)

    ; find the logs which have a number after the basename
    valid_number = bytarr(n_logs)
    for i = 0L, n_logs - 1L do valid_number[i] = mg_str_isnumber(versions[i], type=3)
    valid_indices = where(valid_number eq 1B and dots eq '.', n_valid)

    log_format = '(%"%s.%d")'
    if (n_valid gt 0L) then begin
      valid_versions = long(versions[valid_indices])
      sorted_valid_indices = sort(valid_versions)
      for i = n_valid - 1L, 0L, -1L do begin
        v = valid_versions[sorted_valid_indices[i]]
        if (has_max && (v + 1L gt max_version)) then begin
          file_delete, string(basename, v, format=log_format)
          print, string(basename, v, format=log_format), format='(%"deleting %s")'
        endif else begin
          file_move, string(basename, v, format=log_format), $
                     string(basename, v + 1L, format=log_format)
          print, string(basename, v, format=log_format), $
                 string(basename, v + 1L, format=log_format), $
                 format='(%"%s -> %s")'
        endelse
      endfor
    endif
  endif

  ; move aside basename
  file_move, basename, basename + '.1'
  print, basename, basename + '.1', format='(%"%s -> %s")'
end
