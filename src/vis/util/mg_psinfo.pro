; docformat = 'rst'

;+
; Get/set header information in a PostScript file.
;
; This routine requires `sed` be installed and available in the system path.
;
; :Params:
;    filename : in, required, type=string
;       .ps or .eps file to examine/change attributes of
;
; :Keywords:
;    bounding_box : in, out, optional, type=lonarr(4)
;       if passed an undefined name variable, returns the bounding box for the
;       file; if defined, sets the bounding box to the value
;    hires_bounding_box : in, out, optional, type=fltarr(4)
;       if passed an undefined name variable, returns the hires bounding box
;       for the file; if defined, sets the bounding box to the value
;-
pro mg_psinfo, filename, bounding_box=bb, hires_bounding_box=hires_bb
  compile_opt strictarr

  header = strarr(10)
  openr, lun, filename, /get_lun
  readf, lun, header
  free_lun, lun

  if (n_elements(bb) eq 4L) then begin
    temp_filename = mg_temp_filename('psfile-%s')
    sedCmdF = '(%"sed -e\"s/%%BoundingBox: .*/%%BoundingBox: %d %d %d %d/\" %s > %s")'
    sedCmd = string(bb, filename, temp_filename, format=sedCmdF)
    spawn, sedCmd, sedOutput, sedErrorOutput, exit_status=status
    if (status ne 0L) then message, 'bounding box write failed'

    file_copy, temp_filename, filename, /overwrite
    file_delete, temp_filename
  endif else begin
    if (arg_present(bb)) then begin
      matches = stregex(header, '^%%BoundingBox:', /boolean)
      ind = where(matches, count)
      if (count gt 0L) then begin
        tokens = strsplit(header[ind[0]], /extract)
        bb = float(tokens[1:*])
      endif else message, 'bounding box not found', /informational
    endif
  endelse

  if (n_elements(hires_bb) eq 4L) then begin
    temp_filename = mg_temp_filename('psfile-%s')
    sedCmdF = '(%"sed -e\"s/%%HiResBoundingBox: .*/%%HiResBoundingBox: %f %f %f %f/\" %s > %s")'
    sedCmd = string(hires_bb, filename, temp_filename, format=sedCmdF)
    spawn, sedCmd, sedOutput, sedErrorOutput, exit_status=status
    if (status ne 0L) then message, 'hires bounding box write failed'

    file_copy, temp_filename, filename, /overwrite
    file_delete, temp_filename
  endif else begin
    if (arg_present(hires_bb)) then begin
      matches = stregex(header, '^%%HiResBoundingBox:', /boolean)
      ind = where(matches, count)
      if (count gt 0L) then begin
        tokens = strsplit(header[ind[0]], /extract)
        hires_bb = float(tokens[1:*])
      endif else message, 'hires bounding box not found', /informational
    endif
  endelse
end
