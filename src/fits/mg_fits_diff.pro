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
function mg_fits_diff_getkeywords, header, ignore_keywords=ignore_keywords, $
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
;   logname : in, optional, type=string
;     name of `MG_LOG` logger to send details about differences to
;-
function mg_fits_diff_checkkeywords, header1, filename1, $
                                     header2, filename2, $
                                     ignore_keywords=ignore_keywords, $
                                     logname=logname
  compile_opt strictarr

  keywords1 = mg_fits_diff_getkeywords(header1, ignore_keywords=ignore_keywords, $
                                       n_keywords=n_keywords1)
  keywords2 = mg_fits_diff_getkeywords(header2, ignore_keywords=ignore_keywords, $
                                       n_keywords=n_keywords2)

  n_matches = mg_match(keywords1, keywords2, $
                       a_matches=matches1, b_matches=matches2)

  keywords_diff = 0B

  ; make sure all keywords in filename1 are also in filename2
  notfound_ind1 = mg_complement(matches1, n_keywords1, $
                                count=n_notfound_keywords1)
  if (n_notfound_keywords1 gt 0L) then begin
    if (n_elements(logname) gt 0L) then begin
      mg_log, 'keywords in %s not found in %s: %s', $
              filename1, filename2, strjoin(keywords1[notfound_ind1], ', '), $
              name=logname, /warn
    endif
    keywords_diff = 1B
  endif

  ; make sure all keywords in filename2 are also in filename1
  notfound_ind2 = mg_complement(matches2, n_keywords2, $
                                count=n_notfound_keywords2)
  if (n_notfound_keywords2 gt 0L) then begin
    if (n_elements(logname) gt 0L) then begin
      mg_log, 'keywords in %s not found in %s: %s', $
              filename2, filename1, strjoin(keywords2[notfound_ind2], ', '), $
              name=logname, /warn
    endif
    keywords_diff = 1B
  endif

  if (keywords_diff) then return, keywords_diff

  ; compare values of keywords
  for k = 0L, n_keywords1 - 1L do begin
    key = keywords1[k]
    v1 = sxpar(header1, key)
    v2 = sxpar(header2, key)
    if (v1 ne v2) then begin
      if (n_elements(logname) gt 0L) then begin
        mg_log, 'value for keyword %s not the same, %s ne %s', $
                key, strtrim(v1, 2), strtrim(v2, 2), $
                name=logname, /warn
      endif
      keywords_diff = 1B
      break
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
;   logname : in, optional, type=string
;     name of `MG_LOG` logger to send details about differences to
;-
function mg_fits_diff_checkdata, data1, filename1,$
                                 data2, filename2, $
                                 logname=logname
  compile_opt strictarr

  data_diff = array_equal(size(data1), size(data2)) eq 0
  if (data_diff gt 0L) then begin
    if (n_elements(logname) gt 0L) then begin
      mg_log, 'data in %s not the same size/type as in %s', $
              filename1, filename2, $
              name=logname, /warn
    endif
  endif

  data_diff = array_equal(data1, data2) eq 0
  if (data_diff gt 0L) then begin
    if (n_elements(logname) gt 0L) then begin
      mg_log, 'data in %s not the same as in %s', $
              filename1, filename2, $
              name=logname, /warn
    endif
  endif

  return, data_diff
end


;+
; Determine if two FITS files are equivalent (given some conditions on what to
; check and a numeric tolerance).
;
; Uses `FITS_OPEN`, `FITS_READ`, and `FITS_CLOSE` from SolarSoft library.
;
; :Uses:
;   fits_open, fits_read, fits_close
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
;   logname : in, optional, type=string
;     name of `MG_LOG` logger to send details about differences to
;-
function mg_fits_diff, filename1, filename2, $
                       ignore_keywords=ignore_keywords, $
                       ignore_whitespace=ignore_whitespace, $
                       tolerance=tolerance, $
                       logname=logname
  compile_opt strictarr

  fits_open, filename1, fcb1
  fits_open, filename2, fcb2

  fits_read, fcb1, data1, header1
  fits_read, fcb2, data2, header2

  keywords_diff = mg_fits_diff_checkkeywords(header1, filename1, $
                                             header2, filename2, $
                                             ignore_keywords=ignore_keywords, $
                                             logname=logname)
  if (keywords_diff) then begin
    fits_close, fcb1
    fits_close, fcb2
    return, keywords_diff
  endif

  ; check data
  data_diff = mg_fits_diff_checkdata(data1, filename1, $
                                     data2, filename2, $
                                     logname=logname)
  if (data_diff) then begin
    fits_close, fcb1
    fits_close, fcb2
    return, data_diff
  endif

  extend_diff = fcb1.nextend ne fcb1.nextend
  if (extend_diff gt 0L) then begin
    if (n_elements(logname) gt 0L) then begin
      mg_log, 'number of extensions in %s not the same as in %s', $
              filename1, filename2, $
              name=logname, /warn
    endif
  endif

  for e = 0L, fcb1.nextend - 1L do begin
    fits_read, fcb1, data1, header1, exten_no=e
    fits_read, fcb2, data2, header2, exten_no=e

    keywords_diff = mg_fits_diff_checkkeywords(header1, filename1, $
                                               header2, filename2, $
                                               ignore_keywords=ignore_keywords, $
                                               logname=logname)
    if (keywords_diff) then begin
      fits_close, fcb1
      fits_close, fcb2
      return, keywords_diff
    endif

    data_diff = mg_fits_diff_checkdata(data1, filename1, $
                                       data2, filename2, $
                                       logname=logname)
    if (data_diff) then begin
      fits_close, fcb1
      fits_close, fcb2
      return, data_diff
    endif
  endfor

  fits_close, fcb1
  fits_close, fcb2

  return, 0B
end


; main-level example program

filename1 = filepath('20150428_223017_kcor.fts', $
                     subdir=['..', '..', 'unit', 'fits_ut'], root=mg_src_root())
filename2 = filepath('20150428_223017_kcor_copy.fts', $
                     subdir=['..', '..', 'unit', 'fits_ut'], root=mg_src_root())
print, mg_fits_diff(filename1, filename2)

end
