; docformat = 'rst'

;+
; Print a simple listing of the contents of a FITS file.
;
; :Examples:
;   For example::
;
;     IDL> mg_fits_dump, '20160102_004049_kcor_l1.fts.gz'
;     20160102_004049_kcor_l1.fts.gz [size: 2.1MB 49.8% compression]
;     0: [primary] fltarr(1024, 1024)
;
;   or::
;
;     IDL> mg_fits_dump, '20150802.005205.comp.1074.iqu.3.fts'
;     20150802.005205.comp.1074.iqu.3.fts [size: 13.9MB]
;     0: [primary] 0L
;     1: [I, 1074.50] fltarr(620, 620)
;     2: [I, 1074.62] fltarr(620, 620)
;     3: [I, 1074.74] fltarr(620, 620)
;     4: [Q, 1074.50] fltarr(620, 620)
;     5: [Q, 1074.62] fltarr(620, 620)
;     6: [Q, 1074.74] fltarr(620, 620)
;     7: [U, 1074.50] fltarr(620, 620)
;     8: [U, 1074.62] fltarr(620, 620)
;     9: [U, 1074.74] fltarr(620, 620)
;
; :Params:
;   filename : in, required, type=string
;     filename of FITS file to examine
;
; :Keywords:
;   exten_no : in, optional, type=integer
;     if present, `MG_FITS_DUMP` prints information about the extension given
;   header : in, optional, type=boolean
;     set to print headers
;-
pro mg_fits_dump, filename, exten_no=exten_no, header=print_header
  compile_opt strictarr
  on_error, 2

  if (n_elements(filename) eq 0L) then begin
    message, 'filename argument is required'
  endif

  if (~file_test(filename)) then begin
    message, string(filename, format='(%"%s not found")')
  endif

  ext = strmid(filename, strpos(filename, '.', /reverse_search))
  is_compressed = ext eq '.gz' || ext eq '.ftz' || ext eq '.fz' || ext eq '.Z'

  fits_open, filename, fcb

  full_size = 0.0

  output = []

  for e = 0L, fcb.nextend do begin
    if (n_elements(exten_no) gt 0 && exten_no ne e) then continue
    fits_read, fcb, data, header, exten_no=e

    if (e eq 0L) then begin
      name = fcb.extname[e] eq '' ? 'primary' : fcb.extname[e]
    endif else begin
      name = fcb.extname[e] eq '' ? mg_fits_getkeyword(header, 'XTENSION') : fcb.extname[e]
    endelse

    output = [output, $
              string(e, name, mg_variable_declaration(data), format='(%"%d: [%s] %s")')]

    if (keyword_set(print_header) && ((fcb.nextend eq 0 && e eq 0L) || (n_elements(exten_no) gt 0L && exten_no eq e))) then begin
      if (e ne 0) then begin
        pos = strpos(header, 'BEGIN EXTENSION HEADER')
        ind = where(pos ge 0, count)
        if (count gt 0L) then header = header[ind[0] + 1:*]
      endif
      if (n_elements(header) gt 1L) then begin
        header = header[0:-2]  ; remove 'END'
        output = [output, header]
      endif
    endif

    full_size += total(strlen(header) + 1, /integer) $
                   + n_elements(data) * mg_typesize(size(data, /type))
  endfor

  fits_close, fcb

  compression = is_compressed && n_elements(exten_no) eq 0L $
                  ? string(100.0 * (full_size - fcb.nbytes) / full_size, $
                           format='(%", %0.1f%% compression")') $
                : ''
  print, file_basename(filename), $
         mg_human_size(fcb.nbytes, /si, /long, decimal_places=1), $
         compression, $
         format='(%"%s [size: %s%s]")'

  print, transpose(output)
end


; main-level example program

filename = filepath('20150428_223017_kcor.fts', $
                    subdir=['..', '..', 'unit', 'fits_ut'], root=mg_src_root())
mg_fits_dump, filename
print
mg_fits_dump, filename, exten_no=0

end
