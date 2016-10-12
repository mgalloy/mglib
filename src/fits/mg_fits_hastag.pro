; docformat = 'rst'

;+
; Returns whether the FITS keywords given by `tags` are present in `header`.
;
; :Returns:
;   `bytarr` with the same number of elements as `tags`; scalar byte value if
;   `tags` is a scalar
;
; :Params:
;   header : in, required, type=strarr
;     FITS header
;   tags : in, required, type=byte/bytarr
;     FITS keywords to check header for
;
; :Keywords:
;   count : out, optional, type=integer
;     set to a named variable to retrieve the number of FITS keywords found from
;     the list in `tags`
;-
function mg_fits_hastag, header, tags, count=count
  compile_opt strictarr

  hastag = bytarr(n_elements(tags))
  for t = 0L, n_elements(tags) - 1L do begin
    !null = sxpar(header, tags[t], count=n_parameters)
    hastag[t] = n_parameters gt 0L
  endfor

  count = total(hastag, /integer)

  return, size(tags, /n_dimensions) eq 0L ? hastag[0] : hastag
end


; main-level example program

basename = '20150428_223017_kcor.fts'
filename = filepath(basename, $
                    subdir=['..', '..', 'unit', 'fits_ut'], $
                    root=mg_src_root())

fits_open, filename, fcb
fits_read, fcb, data, header
fits_close, fcb

tags = ['BZERO', 'TEST', 'DARKSHUT']
hastag = mg_fits_hastag(header, tags, count=n_tags)

print, n_tags, n_elements(tags), format='(%"%d of %d tags present")'
for t = 0L, n_elements(tags) - 1L do begin
  print, tags[t], hastag[t] ? 'present' : 'not present', format='(%"%-15s : %s")'
endfor

end
