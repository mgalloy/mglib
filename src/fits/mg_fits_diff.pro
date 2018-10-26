; docformat = 'rst'

;+
; Helper routine to return the keywords in a FITS header.
;
; :Private:
;
; :Returns:
;   `strarr` or `!null` if no keywords
;
; :Params:
;   header : in, required, type=strarr
;     header of a FITS file, as returned via `FITS_READ`
;
; :Keywords:
;   ignore_keywords : in, optional, type=strarr
;     keywords to ignore, may contain wildcards `*` and `?`
;   n_keywords : out, optional, type=long
;     set to a named variable to retrieve the number of keywords found in the
;     header
;-
function mg_fits_diff_getkeywords, header, $
                                   ignore_keywords=ignore_keywords, $
                                   n_keywords=n_keywords
  compile_opt strictarr

  keywords = (stregex(header, '(.{8})=', /subexpr, /extract))[1, *]
  keywords_ind = where(keywords ne '', n_keywords)
  if (n_keywords gt 0L) then begin
    keywords = strtrim(keywords[keywords_ind], 2)
  endif else return, !null

  ignore = bytarr(n_keywords)
  for ik = 0L, n_elements(ignore_keywords) - 1L do begin
    ignore or= strmatch(keywords, ignore_keywords[ik])
  endfor

  keep_ind = where(ignore eq 0L, n_keywords)
  if (n_keywords gt 0L) then begin
    keywords = keywords[keep_ind]
  endif

  return, keywords
end


;+
; Helper routine to check the keywords in a FITS header for differences.
;
; :Private:
;
; :Returns:
;   `0B` if no difference found, `1B` if a difference was found
;
; :Params:
;   header1, header2 : in, required, type=strarr
;     headers of a FITS file, as returned via `FITS_READ`
;   filename1, filename2 : in, required, type=string
;     filenames of FITS files, used for logging
;
; :Keywords:
;   ignore_keywords : in, optional, type=strarr
;     keywords to ignore, may contain wildcards `*` and `?`
;   extension : in, optional, type=long
;     extension number, used for logging
;   differences : in, optional, type=list
;     list of difference messages that can be added to
;-
function mg_fits_diff_checkkeywords, header1, filename1, $
                                     header2, filename2, $
                                     ignore_keywords=ignore_keywords, $
                                     extension=extension, $
                                     differences=differences
  compile_opt strictarr

  _extension = n_elements(extension) eq 0L $
                 ? '' $
                 : string(extension, format='(%" (extension %d)")')

  keywords1 = mg_fits_diff_getkeywords(header1, $
                                       ignore_keywords=ignore_keywords, $
                                       n_keywords=n_keywords1)
  keywords2 = mg_fits_diff_getkeywords(header2, $
                                       ignore_keywords=ignore_keywords, $
                                       n_keywords=n_keywords2)

  n_matches = mg_match(keywords1, keywords2, $
                       a_matches=matches1, b_matches=matches2)

  keywords_diff = 0B

  ; make sure all keywords in filename1 are also in filename2
  notfound_ind1 = mg_complement(matches1, n_keywords1, $
                                count=n_notfound_keywords1)
  if (n_notfound_keywords1 gt 0L) then begin
    if (obj_valid(differences)) then begin
      fmt = '(%"keywords in %s not found in %s: %s%s")'
      differences->add, string(filename1, filename2, $
                               strjoin(keywords1[notfound_ind1], ', '), $
                               _extension, $
                               format=fmt)
    endif
    keywords_diff = 1B
  endif

  ; make sure all keywords in filename2 are also in filename1
  notfound_ind2 = mg_complement(matches2, n_keywords2, $
                                count=n_notfound_keywords2)
  if (n_notfound_keywords2 gt 0L) then begin
    if (obj_valid(differences)) then begin
      fmt = '(%"keywords in %s not found in %s: %s%s")'
      differences->add, string(filename1, filename2, $
                               strjoin(keywords2[notfound_ind2], ', '), $
                               _extension, $
                               format=fmt)
    endif
    keywords_diff = 1B
  endif

  ; compare values of keywords
  for k = 0L, n_keywords1 - 1L do begin
    ; determine if keywords1[k] is in the matching indices
    ind = where(matches1 eq k, count)
    if (count eq 0L) then continue

    key = keywords1[k]
    v1 = mg_fits_getkeyword(header1, key)
    v2 = mg_fits_getkeyword(header2, key)
    if (v1 ne v2) then begin
      if (obj_valid(differences)) then begin
        fmt = '(%"value for keyword %s not the same, %s ne %s%s")'
        differences->add, string(key, strtrim(v1, 2), strtrim(v2, 2), $
                                 _extension, $
                                 format=fmt)
      endif
      keywords_diff = 1B
    endif
  endfor

  return, keywords_diff
end


;+
; Helper routine to check the data in a FITS header for differences.
;
; :Private:
;
; :Returns:
;   `0B` if no difference found, `1B` if a difference was found
;
; :Params:
;   data1, data2 : in, required, type=strarr
;     data of a FITS file, as returned via `FITS_READ`
;   filename1, filename2 : in, required, type=string
;     filenames of FITS files, used for logging
;
; :Keywords:
;   tolerance : in, optional, type=float, default=0.0
;     tolerance to use when comparing data elements
;   extension : in, optional, type=long
;     extension number, used for logging
;   differences : in, optional, type=list
;     list of difference messages that can be added to
;-
function mg_fits_diff_checkdata, data1, filename1,$
                                 data2, filename2, $
                                 tolerance=tolerance, $
                                 extension=extension, $
                                 differences=differences
  compile_opt strictarr

  _extension = n_elements(extension) eq 0L $
                 ? '' $
                 : string(extension, format='(%" (extension %d)")')

  data_diff = array_equal(size(data1), size(data2)) eq 0

  if (data_diff gt 0L && obj_valid(differences)) then begin
    fmt = '(%"data in %s not the same size/type as in %s%s")'
    differences->add, string(filename1, filename2, _extension, format=fmt)
  endif

  if (n_elements(tolerence) gt 0L) then begin
    ind = where(abs(data1 - data2) gt tolerance, count)
    data_diff = count gt 0L
  endif else begin
    data_diff = array_equal(data1, data2) eq 0
  endelse

  if (data_diff gt 0L && obj_valid(differences)) then begin
    fmt = '(%"data in %s not the same as in %s%s")'
    differences->add, string(filename1, filename2, _extension, format=fmt)
  endif

  return, data_diff
end


;+
; Determine if two FITS files are equivalent (given some conditions on what to
; check and a numeric tolerance).
;
; Uses `FITS_OPEN`, `FITS_READ`, and `FITS_CLOSE` from IDL Astronomy
; User's library.
;
; :Examples:
;   For example::
;
;     IDL> filename1 = '20150428_223017_kcor.fts'
;     IDL> filename2 = '20150428_223017_kcor_diffkeywordvalue.fts'
;     IDL> diff = mg_fits_diff(filename1, filename2, differences=diffs)
;     IDL> help, diff
;     DIFF            BYTE      =    1
;     IDL> print, diffs
;     value for keyword OBSSWID not the same, 1.0.6 ne 1.0.7
;
; :Uses:
;   fits_open, fits_read, fits_close, sxpar
;
; :Returns:
;   `0B` if no differences found, `1B` if not
;
; :Params:
;   filename1, filename2 : in, required, type=string
;     filenames of two files to compare
;
; :Keywords:
;   ignore_keywords : in, optional, type=strarr
;     keywords to ignore, may contain wildcards `*` and `?`
;   ignore_whitespace : in, optional, type=boolean
;     set to ignore trailing whitespace in header values
;   tolerance : in, optional, type=float, default=0.0
;     tolerance to use when comparing data elements
;   differences : out, optional, type=strarr
;     set to a named variable to retrieve a an array of difference messages,
;     `!null` if no differences found
;   headers_only : in, optional, type=boolean
;     set to only compare headers
;   error_msg : out, optional, type=string
;     set to a named variable to retrieve any error messages from reading the
;     FITS files; will be the empty string if no error
;-
function mg_fits_diff, filename1, filename2, $
                       ignore_keywords=ignore_keywords, $
                       ignore_whitespace=ignore_whitespace, $
                       tolerance=tolerance, $
                       differences=differences, $
                       headers_only=headers_only, $
                       error_msg=error_msg
  compile_opt strictarr

  fits_open, filename1, fcb1
  fits_open, filename2, fcb2

  fits_read, fcb1, data1, header1, /no_abort, message=error_msg
  if (error_msg ne '') then return, !null

  fits_read, fcb2, data2, header2, /no_abort, message=error_msg
  if (error_msg ne '') then return, !null

  if (arg_present(differences)) then _differences = list()

  diff = 0B
  diff or= mg_fits_diff_checkkeywords(header1, filename1, $
                                      header2, filename2, $
                                      ignore_keywords=ignore_keywords, $
                                      differences=_differences)

  ; check data

  if (not keyword_set(headers_only)) then begin
    diff or= mg_fits_diff_checkdata(data1, filename1, $
                                    data2, filename2, $
                                    differences=_differences)
  endif

  extend_diff = fcb1.nextend ne fcb1.nextend
  if (extend_diff gt 0) then begin
    if (arg_present(differences)) then begin
      fmt = '(%"number of extensions in %s not the same as in %s")'
      _differences->add, string(filename1, filename2, format=fmt)
    endif
  endif
  diff or= extend_diff

  for e = 0L, (fcb1.nextend < fcb2.nextend) - 1L do begin
    fits_read, fcb1, data1, header1, exten_no=e, /no_abort, message=error_msg
    if (error_msg ne '') then return, !null
    fits_read, fcb2, data2, header2, exten_no=e, /no_abort, message=error_msg
    if (error_msg ne '') then return, !null

    diff or= mg_fits_diff_checkkeywords(header1, filename1, $
                                        header2, filename2, $
                                        ignore_keywords=ignore_keywords, $
                                        extension=e, $
                                        differences=_differences)

    if (not keyword_set(headers_only)) then begin
      diff or= mg_fits_diff_checkdata(data1, filename1, $
                                      data2, filename2, $
                                      extension=e, $
                                      differences=_differences)
    endif
  endfor

  fits_close, fcb1
  fits_close, fcb2

  if (arg_present(differences)) then begin
    differences = _differences->toarray()
    obj_destroy, _differences
  endif

  return, diff
end


; main-level example program

filename1 = filepath('20150428_223017_kcor.fts', $
                     subdir=['..', '..', 'unit', 'fits_ut'], root=mg_src_root())
filename2 = filepath('20150428_223017_kcor_copy.fts', $
                     subdir=['..', '..', 'unit', 'fits_ut'], root=mg_src_root())
print, mg_fits_diff(filename1, filename2) ? 'different' : 'same'

filename1 = filepath('20150428_223017_kcor.fts', $
                     subdir=['..', '..', 'unit', 'fits_ut'], root=mg_src_root())
filename2 = filepath('20150428_223017_kcor_diffkeywordvalue.fts', $
                     subdir=['..', '..', 'unit', 'fits_ut'], root=mg_src_root())
print, mg_fits_diff(filename1, filename2, differences=diffs) ? 'different' : 'same'
print, diffs

end
