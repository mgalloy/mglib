; docformat = 'rst'


;+
; Defines `MG_FONTS_TT` structure for installing TrueType fonts.
;
; :Private:
;-
pro mg_fonts_tt__define
  compile_opt strictarr

  !null = { mg_fonts_tt, $
            name: '', $
            filename: '', $
            direct_size: 0., $
            object_size: 0. }
end


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
;
; :Keywords:
;   install : in, optional, type=struct/struct array
;     set to a structure or array of structures of type::
;
;       { mg_fonts_tt, $
;         name: 'Helvetica', $
;         filename: 'tt0003m_.ttf', $
;         direct_size: 0.746957, $
;         object_size: 1.0 }
;
;     where `filename` is a full path to the TrueType font
;   tt_available : out, optional, type=strarr
;     set to a named variable to return the names of the currently available
;     TrueType fonts
;-
pro mg_fonts, install=install, tt_available=tt_available
  compile_opt strictarr
  on_error, 2

  tt_filename = filepath('ttfont.map', subdir=['resource', 'fonts', 'tt'])

  if (n_elements(install) gt 0L) then begin
    case (size(install, /structure)).structure_name of
      'MG_FONTS_TT': begin
          for i = 0L, n_elements(install) - 1L do begin
            !null = mg_filename(install[i].filename, extension=ext)
            if (ext ne 'ttf') then begin
              message, string(install[i].filename, $
                              format='(%"not a .ttf file: %s")')
            endif
            openu, lun, tt_filename, /get_lun, /append
            printf, lun, $
                    install[i].name, $
                    file_basename(install[i].filename), $
                    install[i].direct_size, $
                    install[i].object_size, $
                    format='(%"\"%s\"   %s   %f   %f")'
            free_lun, lun
            file_copy, install[i].filename, $
                       filepath('', subdir=['resource', 'fonts', 'tt']), $
                       /overwrite
          endfor
        end
      else: message, 'invalid install structure'
    endcase
  endif

  if (arg_present(tt_available)) then begin
    fonts = mg_file(tt_filename, /readf)
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
