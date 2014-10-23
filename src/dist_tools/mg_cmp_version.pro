; docformat = 'rst'


;+
; Determine if the input string represents an integer.
;
; :Private:
;
; :Returns:
;   boolean
;
; :Params:
;   p1 : in, required, type=string
;     input string
;-
function mg_cmp_version_isinteger, p1
  compile_opt strictarr

  return, stregex(p1, '^[[:digit:]]+$', /boolean)
end


;+
; Compare a place in a version number.
;
; :Private:
;
; :Returns:
;   0 for equal, 1 for p1 gt p2, -1 for p1 lt p2
;
; :Params:
;   p1 : in, required, type=string
;     one digit of a version number
;   p2 : in, required, type=string
;     one digit of a version number
;-
function mg_cmp_version_cmp, p1, p2
  compile_opt strictarr

  if (p1 eq '' && p2 ne '') then return, 1
  if (p2 eq '' && p1 ne '') then return, -1

  if (mg_cmp_version_isinteger(p1) && mg_cmp_version_isinteger(p2)) then begin
    _p1 = long(p1)
    _p2 = long(p2)
  endif else begin
    _p1 = p1
    _p2 = p2
  endelse

  case 1 of
    _p1 lt _p2: return, -1
    _p1 gt _p2: return, 1
    _p1 eq _p2: return, 0
  endcase
end


;+
; Decomposes a full version number into `MAJOR.MINOR.PATCH` with optional
; prerelease and build information.
;
; :Private:
;
; :Returns:
;   `lonarr(3)`
;
; :Params:
;   version : in, required, type=string
;     version string of the form '1.2.3' or '1.2.3-prereleaseinfo+buildinfo'
;
; :Keywords:
;   build_info : out, optional, type=string
;     set to a named variable to return the build information if present in the
;     version string
;   prerelease_info : out, optional, type=string
;     set to a named variable to return the prerelease information if present
;     in the version string
;   error : out, optional, type=long
;     set to a named variable to return the error status, 0 for no error
;-
function mg_cmp_version_decompose, version, $
                                   build_info=build_info, $
                                   prerelease_info=prerelease_info, $
                                   error=error
  compile_opt strictarr

  error = 0L
  re = '([[:digit:]\.]+)-?([^\+]*)\+?(.*)'
  tokens = stregex(version, re, /extract, /subexpr)

  prerelease_info = strsplit(tokens[2], '.', /extract)
  build_info = tokens[3]

  vparts = strsplit(tokens[1], '.', /extract, count=vlen)
  if (vlen gt 3L) then begin
    error = 1L
    vparts = vparts[0:2]
  endif

  _version = lonarr(3)
  _version[0] = long(vparts)

  return, _version
end


;+
; Compares two version numbers for the more updated number. Returns `0` for
; equal versions, `1` if `version1` is later than `version2`, and -1 if
; `version1` is earlier than `version2`. Strings such as 'alpha' and 'beta'
; may be tacked on to the end of a version, but are compared alphabetically.
;
; See `Semantic versioning <http://semver.org>` for details.
;
; :Examples:
;   For example, 1.2 is later than 1.1.2::
;
;     IDL> print, mg_cmp_version('1.2', '1.1.2')
;            1
;
;   And 1.2 is earlier than 1.3::
;
;     IDL> print, mg_cmp_version('1.2', '1.3')
;           -1
;
;   And 1.2 is equivalent to itself::
;
;     IDL> print, mg_cmp_version('1.2', '1.2')
;            0
;
;   Also, try the main-level example program at the end of this file::
;
;     IDL> .run mg_cmp_version
;                       1.2    1.1.2      1.1    1.1.0    1.1-b    1.1-a   1.1-10  1.1-1.1  1.1-0.1
;           1.2 >         0        1        1        1        1        1        1        1        1
;         1.1.2 >        -1        0        1        1        1        1        1        1        1
;           1.1 >        -1       -1        0        0        1        1        1        1        1
;         1.1.0 >        -1       -1        0        0        1        1        1        1        1
;         1.1-b >        -1       -1       -1       -1        0        1        1        1        1
;         1.1-a >        -1       -1       -1       -1       -1        0        1        1        1
;        1.1-10 >        -1       -1       -1       -1       -1       -1        0        1        1
;       1.1-1.1 >        -1       -1       -1       -1       -1       -1       -1        0        1
;       1.1-0.1 >        -1       -1       -1       -1       -1       -1       -1       -1        0
;
; :Returns:
;   `-1`, `0`, or `1`
;
; :Params:
;   version1 : in, required, type=string
;     first version number
;   version2 : in, required, type=string
;     second version number
;
; :Keywords:
;   error : out, optional, type=long
;     error code, 0 for success
;-
function mg_cmp_version, version1, version2, error=error
  compile_opt strictarr
  on_error, 2

  error = 0L

  version_values_1 = mg_cmp_version_decompose(version1, $
                                              prerelease_info=pr_info_1, $
                                              error=error_1)
  version_values_2 = mg_cmp_version_decompose(version2, $
                                              prerelease_info=pr_info_2, $
                                              error=error_2)

  error or= error_1 or error_2
  if (error gt 0L) then return, 0

  for i = 0L, 2L do begin
    if (version_values_1[i] gt version_values_2[i]) then return, 1
    if (version_values_1[i] lt version_values_2[i]) then return, -1
  endfor

  pr_parts = n_elements(pr_info_1) < n_elements(pr_info_2)

  for i = 0L, pr_parts - 1L do begin
    c = mg_cmp_version_cmp(pr_info_1[i], pr_info_2[i])
    if (c ne 0L) then return, c
  endfor

  if (n_elements(pr_info_1) gt n_elements(pr_info_2)) then return, 1
  if (n_elements(pr_info_1) lt n_elements(pr_info_2)) then return, -1

  return, 0
end


; main-level example

v = ['1.2', '1.1.2', '1.1', '1.1.0', '1.1-b', '1.1-a', '1.1-10', '1.1-1.1', '1.1-0.1']
colwidth = max(strlen(v)) + 2

format_header = string(n_elements(v), colwidth, format='(%"(%dA%d)")')
format_result = string(colwidth, format='(%"(I%d, $)")')
format_left = string(colwidth + 3, format='(%"(A%d, $)")')

print, '', format=format_left
print, v, format=format_header

for v1 = 0L, n_elements(v) - 1L do begin
  print, v[v1] + ' > ', format=format_left
  for v2 = 0L, n_elements(v) - 1L do begin
    print, mg_cmp_version(v[v1], v[v2]), $
           format=format_result
  endfor
  print
endfor

end
