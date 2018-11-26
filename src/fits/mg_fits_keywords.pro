; docformat = 'rst'

;+
; Return the FITS keywords present in a FITS header -- does not include COMMENT,
; HISTORY, or continuation lines.
;
; :Returns:
;   `strarr`
;
; :Params:
;   header : in, required, type=strarr
;     FITS header
;
; :Keywords:
;   count : out, optional, type=long
;     set to a named variable to retrieve the number of FITS keyword present in
;     the header
;-
function mg_fits_keywords, header, count=count
  compile_opt strictarr

  keywords = strtrim(strmid(header, 0, 8), 2)
  is_keyword = strmid(header, 8, 1) eq '='
  keyword_indices = where(is_keyword, count)
  return, keywords[keyword_indices]
end
