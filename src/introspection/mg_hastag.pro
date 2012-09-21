; docformat = 'rst'

;+
; Determines if a structure has a given tag name.
;
; :Returns:
;    1B if structure has the tagname, 0B if not
;
; :Params:
;    s : in, required, type=structure
;       structure to check
;    tagname : in, required, type=string
;       name of field to check for
;-
function mg_hastag, s, tagname
  compile_opt strictarr

  ind = where(strcmp(tagname, tag_names(s), /fold_case) eq 1L, count)
  return, count gt 0L
end
