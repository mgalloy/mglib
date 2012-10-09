; docformat = 'rst'

;+
; Compare two structures for equality.
;
; :Returns:
;    1 if equal, 0 if not
;
; :Params:
;    s1 : in, required, type=structure
;       first structure to compare
;    s2 : in, required, type=structure
;       second structure to compare
;
; :Keywords:
;    no_typeconv : in, optional, type=boolean
;       set to declare structures as different if the fields have different
;       types, even if the values are equal
;-
function mg_struct_equal, s1, s2, no_typeconv=noTypeconv
  compile_opt strictarr

  ntags1 = n_tags(s1)
  ntags2 = n_tags(s2)

  if (ntags1 ne ntags2) then return, 0B
  if (~array_equal(tag_names(s1), tag_names(s2))) then return, 0B

  for t = 0L, ntags1 - 1L do begin
    tagType1 = size(s1.(t), /type)
    tagType2 = size(s2.(t), /type)

    if (keyword_set(noTypeconv) && tagType1 ne tagType2) then return, 0B

    if ((tagType1 eq 8 && tagType2 ne 8) $
          || (tagType1 ne 8 && tagType2 eq 8)) then return, 0B

    if (tagType1 eq 8) then begin
      equal = mg_struct_equal(s1.(t), s2.(t), no_typeconv=noTypeConv)
      if (~equal) then return, 0B
    endif else begin
      if (s1.(t) ne s2.(t)) then return, 0B
    endelse
  endfor

  return, 1B
end
