; docformat = 'rst'

;+
; Compares two version numbers for the more updated number. Returns `0` for
; equal versions, `1` if `version1` is later than `version2`, and -1 if
; `version1` is earlier than `version2`. Strings such as 'alpha' and 'beta'
; may be tacked on to the end of a version, but are compared alphabetically.
;
;
; :Examples:
;    For example, 1.2 is later than 1.1.2::
;
;       IDL> print, mg_cmp_version('1.2', '1.1.2')
;              1
;
;    And 1.2 is earlier than 1.3::
;
;       IDL> print, mg_cmp_version('1.2', '1.3')
;             -1
;
;    And 1.2 is equivalent to itself::
;
;       IDL> print, mg_cmp_version('1.2', '1.2')
;              0
;
;    Also, try the main-level example program at the end of this file::
;
;       IDL> .run mg_cmp_version
;                           1.2     1.1.2       1.1  1.1alpha   1.1beta
;              1.2 >          0         1         1         1         1
;            1.1.2 >         -1         0         1         1         1
;              1.1 >         -1        -1         0         1         1
;         1.1alpha >         -1        -1        -1         0        -1
;          1.1beta >         -1        -1        -1         1         0
;
; :Returns:
;    -1, 0, or 1
;
; :Params:
;    version1 : in, required, type=string
;       first version number
;    version2 : in, required, type=string
;       second version number
;-
function mg_cmp_version, version1, version2
  compile_opt strictarr

  v1parts = strsplit(version1, '.', /extract, count=v1len)
  v2parts = strsplit(version2, '.', /extract, count=v2len)

  nparts = v1len > v2len

  v1partsValues = lonarr(nparts)
  v2partsValues = lonarr(nparts)

  v1partsValues[0] = long(v1parts)
  v2partsValues[0] = long(v2parts)

  for i = 0L, nparts - 1L do begin
    if (v1partsValues[i] gt v2partsValues[i]) then return, 1
    if (v1partsValues[i] lt v2partsValues[i]) then return, -1

    if (i eq nparts - 1L) then begin
      nondigitpos1 = i lt v1len ? stregex(v1parts[i], '[^[:digit:].]') : -1
      nondigitpos2 = i lt v2len ? stregex(v2parts[i], '[^[:digit:].]') : -1

      if (nondigitpos1 eq -1L && nondigitpos2 eq -1L) then return, 0
      if (nondigitpos1 eq -1L) then return, 1
      if (nondigitpos2 eq -1L) then return, -1

      case 1 of
        v1parts[i] lt v2parts[i]: return, -1
        v1parts[i] gt v2parts[i]: return, 1
        else : return, 0
      endcase
    endif
  endfor

  return, 0
end


; main-level example

v = ['1.2', '1.1.2', '1.1', '1.1alpha', '1.1beta']
colwidth = max(strlen(v)) + 2

print, '', format='(A13, $)'
print, v, format='(5A10)'

for v1 = 0L, n_elements(v) - 1L do begin
  print, v[v1] + ' > ', format='(A13, $)'
  for v2 = 0L, n_elements(v) - 1L do begin
    print, mg_cmp_version(v[v1], v[v2]), $
           format='(I10, $)'
  endfor
  print
endfor

end