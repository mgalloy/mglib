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
function mg_fits_diff_keywords, header, ignore_keywords=ignore_keywords, $
                                n_keywords=n_keywords
  compile_opt strictarr

  keywords = (stregex(header, '(.{8})=', /subexpr, /extract))[1, *]
  keywords_ind = where(keywords ne '', n_keywords)
  if (n_keywords gt 0L) then begin
    keywords = strtrim(keywords[keywords_ind], 2)
  endif else keywords = !null

  return, keywords
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
;   `1B` if equivalent, `0B` if not
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
  fits_read, fcb1, data1, header1, /header_only
  fits_close, fcb1

  fits_open, filename2, fcb2
  fits_read, fcb2, data2, header2, /header_only
  fits_close, fcb2

  keywords1 = mg_fits_diff_keywords(header1, ignore_keywords=ignore_keywords, $
                                    n_keywords=n_keywords1)
  keywords2 = mg_fits_diff_keywords(header2, ignore_keywords=ignore_keywords, $
                                    n_keywords=n_keywords2)

  n_matches = mg_match(keywords1, keywords2, $
                       a_matches=matches1, b_matches=matches2)

  notfound_ind1 = mg_complement(matches1, n_keywords1, count=n_notfound_keywords1)
  notfound_ind2 = mg_complement(matches2, n_keywords2, count=n_notfound_keywords2)

  keywords_diff = 0B

  if (n_notfound_keywords1 gt 0L) then begin
    if (n_elements(logname) gt 0L) then begin
      mg_log, 'keywords in %s not found in %s: %s', $
              filename1, filename2, strjoin(keywords1[notfound_ind1], ', '), $
              name=logname, /warn
    endif
    keywords_diff = 1B
  endif

  if (n_notfound_keywords2 gt 0L) then begin
    if (n_elements(logname) gt 0L) then begin
      mg_log, 'keywords in %s not found in %s: %s', $
              filename2, filename1, strjoin(keywords2[notfound_ind2], ', '), $
              name=logname, /warn
    endif
    keywords_diff = 1B
  endif

  if (keywords_diff) then return, keywords_diff

  return, 1B
end


; main-level example program

filename1 = filepath('20150428_223017_kcor.fts', $
                     subdir=['..', '..', 'unit', 'fits_ut'], root=mg_src_root())
filename2 = filepath('20150428_223017_kcor_copy.fts', $
                     subdir=['..', '..', 'unit', 'fits_ut'], root=mg_src_root())
print, mg_fits_diff(filename1, filename2)

end
