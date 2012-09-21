; docformat = 'rst'

;+
; Returns the newline separator(s) for the OS: linefeed on UNIX platforms and
; carriage return/linefeeds for Windows.
; 
; :Examples:
;    It can be useful to create a single string from a string array in some 
;    cases::
;
;       IDL> sarr = strtrim(indgen(10), 2)
;       IDL> print, strjoin(sarr, vis_newline())
;
; :Returns:
;    string
;
; :Keywords:
;    unix : in, optional, type=boolean
;       use just linefeed
;    windows : in, optional, type=boolean
;       use carriage return and linefeed
;-
function vis_newline, unix=unix, windows=windows
  compile_opt strictarr
  
  case 1 of
    keyword_set(unix): crlf = string([10B])
    keyword_set(windows): crlf = string([13B, 10B])
    else: crlf = string(!version.os_family eq 'unix' ? [10B] : [13B, 10B])
  endcase
  
  return, crlf
end