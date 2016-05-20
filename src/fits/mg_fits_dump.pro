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
;-
pro mg_fits_dump, filename
  compile_opt strictarr

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
    fits_read, fcb, data, header, exten_no=e
    name = (fcb.extname[e] eq '' && e eq 0L) ? 'primary' : fcb.extname[e]
    output = [output, $
              string(e, name, mg_variable_declaration(data), format='(%"%d: [%s] %s")')]

    full_size += total(strlen(header) + 1, /integer) $
                   + n_elements(data) * mg_typesize(size(data, /type))
  endfor

  fits_close, fcb

  compression = is_compressed $
                  ? string(100.0 * (full_size - fcb.nbytes) / full_size, $
                           format='(%", %0.1f%% compression")') $
                : ''
  print, file_basename(filename), $
         mg_human_size(fcb.nbytes, /si, /long, decimal_places=1), $
         compression, $
         format='(%"%s [size: %s%s]")'

  print, transpose(output)
end
