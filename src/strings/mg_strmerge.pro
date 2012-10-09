; docformat = 'rst'

;+
; Merges a string array into a single string separated by carriage
; return/linefeeds.
;
; Defaults to use just linefeed on UNIX platforms and both carriage returns
; and linefeeds on Windows platforms unless the UNIX or WINDOWS keywords are
; set to force a particular separator.
;
; :Returns:
;    string
;
; :Params:
;    s : in, required, type=strarr
;       string array to merge
;
; :Keywords:
;    unix : in, optional, type=boolean
;       use just linefeed
;    windows : in, optional, type=boolean
;       use carriage return and linefeed
;-
function mg_strmerge, s, unix=unix, windows=windows
  compile_opt strictarr

  return, strjoin(s, mg_newline(unix=unix, windows=windows))
end
