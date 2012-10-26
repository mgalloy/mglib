; docformat = 'rst'

;+
; Utility to query fonts available in the system.
;
; :Examples:
;   For example, to find the names of the TrueType fonts available to use with
;   the `SET_FONT` keyword to `DEVICE`, use::
;
;     IDL> mg_fonts, tt_available=tt_available
;     IDL> print, transpose(tt_available)
;     IDL> device, set_font=tt_available[-1], /tt_font
;     IDL> xyouts, 0.5, 0.5, 'Hello!', alignment=0.5, charsize=6.0, font=1
;-
pro mg_fonts, tt_available=tt_available
  compile_opt strictarr

  if (arg_present(tt_available)) then begin
    filename = filepath('ttfont.map', subdir=['resource', 'fonts', 'tt'])
    fonts = mg_file(filename, /readf)
    valid = stregex(fonts, '^[^#]', /boolean)
    ind = where(valid, nvalid)
    if (nvalid eq 0L) then begin
      tt_available = !null
    endif else begin
      matches = stregex(fonts[ind], '"(.+)".+', /extract, /subexpr)
      tt_available = reform(matches[1, *])
      ind = where(tt_available, nvalid)
      if (nvalid eq 0L) then begin
        tt_available = !null
      endif else begin
        tt_available = tt_available[ind]
      endelse
    endelse
  endif
end


; main-level example program

basename = 'last-font'
mg_psbegin, /image, filename=basename + '.ps', xsize=6, ysize=4, /inches


mg_fonts, tt_available=tt_available
print, 'TrueType fonts available:'
print, transpose('  ' + tt_available)
device, set_font=tt_available[-1], /tt_font
xyouts, 0.5, 0.5, 'Hello!', alignment=0.5, charsize=6.0, font=1

mg_psend
mg_convert, basename, max_dimensions=[500, 500], output=im, /cleanup
mg_image, im, /new_window

end
